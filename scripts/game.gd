extends Node

var day: int = 1
var time_of_day: float = 8.0
var season_names: Array = ["Spring", "Summer", "Autumn", "Winter"]
var season_index: int = 0
var money: int = 50
var inventory: Dictionary = {}
var items: Dictionary = {}
var crop_map: Dictionary = {}
var crop_count: int = 0

signal inventory_changed
signal time_changed
signal season_changed
signal money_changed

func _ready() -> void:
    _init_items()
    add_item("seed_potato", 5)
    add_item("seed_tomato", 3)
    set_process(true)

func _process(delta: float) -> void:
    time_of_day += delta * (24.0 / 240.0)
    if time_of_day >= 24.0:
        time_of_day -= 24.0
        day += 1
        if day % 10 == 0:
            season_index = (season_index + 1) % season_names.size()
            emit_signal("season_changed", season_names[season_index])
    emit_signal("time_changed", day, season_names[season_index], time_of_day)

func _init_items() -> void:
    items["seed_potato"] = {"name": "Potato Seed", "type": "seed", "price": 6, "crop": "crop_potato", "allowed_seasons": ["Spring", "Summer"]}
    items["seed_tomato"] = {"name": "Tomato Seed", "type": "seed", "price": 9, "crop": "crop_tomato", "allowed_seasons": ["Summer", "Autumn"]}
    items["crop_potato"] = {"name": "Potato", "type": "crop", "price": 11}
    items["crop_tomato"] = {"name": "Tomato", "type": "crop", "price": 14}
    items["fertilizer"] = {"name": "Fertilizer", "type": "craft", "price": 0}

func add_item(item_id: String, amount: int) -> void:
    if amount <= 0:
        return
    inventory[item_id] = inventory.get(item_id, 0) + amount
    emit_signal("inventory_changed")

func remove_item(item_id: String, amount: int) -> bool:
    if inventory.get(item_id, 0) < amount:
        return false
    inventory[item_id] -= amount
    if inventory[item_id] <= 0:
        inventory.erase(item_id)
    emit_signal("inventory_changed")
    return true

func buy_item(item_id: String, amount: int = 1) -> bool:
    if not items.has(item_id):
        return false
    var price = int(items[item_id].price) * amount
    if money < price:
        return false
    money -= price
    add_item(item_id, amount)
    emit_signal("money_changed", money)
    return true

func sell_item(item_id: String, amount: int = 1) -> bool:
    if not inventory.has(item_id):
        return false
    if inventory[item_id] < amount:
        return false
    if not items.has(item_id):
        return false
    var sell_value = int(items[item_id].price * 0.6) * amount
    remove_item(item_id, amount)
    money += sell_value
    emit_signal("money_changed", money)
    return true

func craft_fertilizer() -> bool:
    if inventory.get("crop_potato", 0) < 2:
        return false
    if remove_item("crop_potato", 2):
        add_item("fertilizer", 1)
        return true
    return false

func get_season_name() -> String:
    return season_names[season_index]

func can_plant_in_current_season(seed_id: String) -> bool:
    if not items.has(seed_id):
        return false
    var allowed = items[seed_id].get("allowed_seasons", [])
    if allowed.is_empty():
        return true
    return allowed.has(get_season_name())

func world_to_cell(world_pos: Vector2) -> Vector2:
    return Vector2(floor(world_pos.x / 32.0), floor(world_pos.y / 32.0))

func plant_seed_at(world_pos: Vector2, seed_id: String, parent: Node) -> bool:
    if not inventory.has(seed_id):
        return false
    if not can_plant_in_current_season(seed_id):
        return false
    var cell = world_to_cell(world_pos)
    var key = str(cell.x) + ":" + str(cell.y)
    if crop_map.has(key):
        return false
    var crop_scene = preload("res://scenes/Crop.tscn")
    var crop = crop_scene.instantiate()
    crop.position = cell * 32.0 + Vector2(16, 16)
    crop.set_seed(seed_id)
    parent.add_child(crop)
    crop_map[key] = crop
    crop_count += 1
    remove_item(seed_id, 1)
    return true

func harvest_at(world_pos: Vector2) -> Dictionary:
    var cell = world_to_cell(world_pos)
    var key = str(cell.x) + ":" + str(cell.y)
    if not crop_map.has(key):
        return {}
    var crop = crop_map[key]
    if crop == null or not is_instance_valid(crop):
        crop_map.erase(key)
        return {}
    var result = crop.harvest()
    if result.is_empty():
        return {}
    crop.queue_free()
    crop_map.erase(key)
    crop_count -= 1
    add_item(result["item_id"], result["amount"])
    return result

func save_game(path: String = "user://savegame.json") -> void:
    var data = {
        "day": day,
        "time_of_day": time_of_day,
        "season_index": season_index,
        "money": money,
        "inventory": inventory
    }
    var file = FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(data))
    file.close()

func load_game(path: String = "user://savegame.json") -> void:
    if not FileAccess.file_exists(path):
        return
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return
    var text = file.get_as_text()
    file.close()
    var data = JSON.parse_string(text)
    if typeof(data) != TYPE_DICTIONARY:
        return
    day = int(data.get("day", day))
    time_of_day = float(data.get("time_of_day", time_of_day))
    season_index = int(data.get("season_index", season_index))
    money = int(data.get("money", money))
    inventory = data.get("inventory", inventory)
    emit_signal("inventory_changed")
    emit_signal("money_changed", money)
    emit_signal("time_changed", day, season_names[season_index], time_of_day)

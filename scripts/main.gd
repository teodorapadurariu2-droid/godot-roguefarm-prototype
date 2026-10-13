extends Node2D

@onready var player: Node2D = $Player
@onready var status_label: Label = $CanvasLayer/Hud/StatusLabel
@onready var inventory_label: Label = $CanvasLayer/Hud/InventoryLabel
@onready var money_label: Label = $CanvasLayer/Hud/MoneyLabel
@onready var time_label: Label = $CanvasLayer/Hud/TimeLabel
@onready var shop_panel: Control = $CanvasLayer/Hud/ShopPanel
@onready var craft_panel: Control = $CanvasLayer/Hud/CraftPanel
@onready var buy_potato: Button = $CanvasLayer/Hud/ShopPanel/BuyPotato
@onready var buy_tomato: Button = $CanvasLayer/Hud/ShopPanel/BuyTomato
@onready var craft_fertilizer: Button = $CanvasLayer/Hud/CraftPanel/CraftFertilizer

var shop_open: bool = false
var craft_open: bool = false

func _ready() -> void:
    Game.connect("inventory_changed", _refresh_ui)
    Game.connect("time_changed", _on_time_changed)
    Game.connect("money_changed", _on_money_changed)
    _refresh_ui()
    _on_time_changed(Game.day, Game.get_season_name(), Game.time_of_day)
    _on_money_changed(Game.money)
    shop_panel.visible = false
    craft_panel.visible = false
    _bind_ui()

func _bind_ui() -> void:
    buy_potato.pressed.connect(func(): Game.buy_item("seed_potato", 1))
    buy_tomato.pressed.connect(func(): Game.buy_item("seed_tomato", 1))
    craft_fertilizer.pressed.connect(func():
        if Game.craft_fertilizer():
            status_label.text = "Crafted fertilizer!"
        else:
            status_label.text = "Need 2 potatoes for fertilizer."
    )

func _process(delta: float) -> void:
    var input_vector := Vector2.ZERO
    if Input.is_action_pressed("ui_left"):
        input_vector.x -= 1
    if Input.is_action_pressed("ui_right"):
        input_vector.x += 1
    if Input.is_action_pressed("ui_up"):
        input_vector.y -= 1
    if Input.is_action_pressed("ui_down"):
        input_vector.y += 1
    player.set_move_input(input_vector, Input.is_action_pressed("ui_accept"))

    if Input.is_action_just_pressed("interact"):
        player.interact()
    if Input.is_action_just_pressed("shop"):
        shop_open = !shop_open
        shop_panel.visible = shop_open
        craft_panel.visible = false
        craft_open = false
    if Input.is_action_just_pressed("craft"):
        craft_open = !craft_open
        craft_panel.visible = craft_open
        shop_panel.visible = false
        shop_open = false

func _refresh_ui() -> void:
    var text = "Inventory: "
    if Game.inventory.is_empty():
        text += "empty"
    else:
        text += ""
        for key in Game.inventory.keys():
            var item_name = Game.items.get(key, {}).get("name", key)
            text += item_name + " x" + str(Game.inventory[key]) + ", "
        text = text.rstrip(", ")
    inventory_label.text = text
    money_label.text = "Coins: %d" % Game.money
    time_label.text = "Day %d • %s • %s" % [Game.day, Game.get_season_name(), _format_time(Game.time_of_day)]

func _on_time_changed(day_value: int, season_name: String, time_value: float) -> void:
    time_label.text = "Day %d • %s • %s" % [day_value, season_name, _format_time(time_value)]

func _on_money_changed(value: int) -> void:
    money_label.text = "Coins: %d" % value

func _format_time(value: float) -> String:
    var hours = int(floor(value))
    var minutes = int(round((value - hours) * 60.0))
    if minutes >= 60:
        minutes = 0
        hours += 1
        if hours >= 24:
            hours = 0
    return "%02d:%02d" % [hours, minutes]

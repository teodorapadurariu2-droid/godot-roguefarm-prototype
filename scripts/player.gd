extends Node2D

var move_vector: Vector2 = Vector2.ZERO
var sprinting: bool = false
var speed: float = 120.0
var sprint_speed: float = 185.0
var max_stamina: float = 100.0
var stamina: float = 100.0
var stamina_regen: float = 12.0
var stamina_drain: float = 18.0

func _process(delta: float) -> void:
    if sprinting and stamina > 0.0:
        stamina = max(0.0, stamina - stamina_drain * delta)
        if stamina <= 0.0:
            sprinting = false
    else:
        stamina = min(max_stamina, stamina + stamina_regen * delta)
    if move_vector.length() > 0.0:
        var effective_speed = sprint_speed if sprinting and stamina > 0.0 else speed
        position += move_vector.normalized() * effective_speed * delta
    position.x = clamp(position.x, 0.0, 640.0)
    position.y = clamp(position.y, 0.0, 360.0)

func set_move_input(input_vector: Vector2, should_sprint: bool) -> void:
    move_vector = input_vector
    sprinting = should_sprint

func interact() -> void:
    var harvest_result = Game.harvest_at(global_position)
    if harvest_result.is_empty():
        var seed_id = ""
        for key in Game.inventory.keys():
            if Game.items.get(key, {}).get("type", "") == "seed":
                seed_id = key
                break
        if seed_id != "":
            Game.plant_seed_at(global_position, seed_id, get_parent())

func get_stamina_percent() -> float:
    return stamina / max_stamina

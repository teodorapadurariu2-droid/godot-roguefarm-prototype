extends Node2D

var seed_id: String = ""
var growth: float = 0.0
var grow_time: float = 18.0
var grown: bool = false
var textures: Dictionary = {
    "seed_potato": preload("res://art/seed_potato.svg"),
    "seed_tomato": preload("res://art/seed_tomato.svg"),
    "crop_potato": preload("res://art/crop_potato.svg"),
    "crop_tomato": preload("res://art/crop_tomato.svg")
}

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    if seed_id == "":
        set_seed("seed_potato")
    sprite.texture = textures.get(seed_id, textures["seed_potato"])

func set_seed(item_id: String) -> void:
    seed_id = item_id
    match item_id:
        "seed_potato":
            grow_time = 18.0
        "seed_tomato":
            grow_time = 25.0
        _:
            grow_time = 18.0
    if sprite:
        sprite.texture = textures.get(seed_id, textures["seed_potato"])

func _process(delta: float) -> void:
    if grown:
        return
    growth += delta
    if growth >= grow_time:
        grown = true
        sprite.texture = textures.get(item_result_id(), textures["crop_potato"])

func item_result_id() -> String:
    if seed_id == "seed_potato":
        return "crop_potato"
    if seed_id == "seed_tomato":
        return "crop_tomato"
    return "crop_potato"

func harvest() -> Dictionary:
    if not grown:
        return {}
    var result = {"item_id": item_result_id(), "amount": 1}
    return result

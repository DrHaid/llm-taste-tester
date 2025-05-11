extends Node3D

signal cook_food(foods: Array[FoodItemData])
signal cooking_finished(successful: bool)

@onready var stew_model: Node3D = $StewModel
@onready var stew_full_target: Marker3D = $StewFullTarget
@onready var food_detector: Area3D = $FoodDetector

@export var cooking_speed: float = 2

var stew_start: Vector3 = Vector3.ZERO

func _ready() -> void:
	stew_start = stew_model.global_position

func raise_stew_level(food_count: int) -> void:
	var level: float = clamp(food_count, 2.0, 5.0) / 5.0
	var stew_rising_dir := stew_full_target.global_position - stew_start
	var stew_target_pos := stew_start + (stew_rising_dir * level)
	var stew_tween := create_tween()
	stew_tween.tween_property(stew_model, "global_position", stew_target_pos, cooking_speed)
	stew_tween.finished.connect(_finish_cooking)

func set_stove_cooking() -> bool:
	var foods := _get_foods_for_cooking()
	if not foods:
		cooking_finished.emit(false)
		return false

	for food: RigidBody3D in foods:
		food.set_cooking(true, cooking_speed)
	var food_res: Array[FoodItemData]
	food_res.assign(foods.map(func(f: Node3D) -> FoodItemData: return f.food_resource))
	cook_food.emit(food_res)
	
	stew_model.visible = true
	raise_stew_level(foods.size())
	return true

func _finish_cooking() -> void:
	cooking_finished.emit(true)

func _get_foods_for_cooking() -> Array:
	var nodes := food_detector.get_overlapping_bodies()
	var foods := nodes.filter(func(f: Node3D) -> bool: return f.is_in_group(&"Food"))
	return foods

func reset() -> void:
	stew_model.global_position = stew_start
	stew_model.visible = false

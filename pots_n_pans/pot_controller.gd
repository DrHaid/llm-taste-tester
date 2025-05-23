extends Node3D

signal cook_food(foods: Array[FoodItemData])
signal cooking_finished(successful: bool)

@onready var pot_collider: StaticBody3D = $PotCollider
@onready var pot_collider_no_bottom: StaticBody3D = $PotColliderNoBottom
@onready var pot_collider_bottom: RigidBody3D = $PotColliderBottom
@onready var pot_collider_bottom_target: Marker3D = $PotColliderBottomTarget
@onready var stew_model: Node3D = $StewModel
@onready var stew_target: Marker3D = $StewTarget
@onready var food_detector: Area3D = $FoodDetector

@export var cooking_speed: float = 2

var col_bottom_start: Vector3 = Vector3.ZERO
var stew_start: Vector3 = Vector3.ZERO

func _ready() -> void:
	col_bottom_start = pot_collider_bottom.global_position
	stew_start = stew_model.global_position

func _set_collider_cooking(cooking: bool) -> void:
	stew_model.visible = cooking
	pot_collider.get_child(0).disabled = cooking
	pot_collider_no_bottom.get_child(0).disabled = not cooking
	pot_collider_bottom.get_child(0).disabled = not cooking

func raise_stew_level() -> void:
	var stew_tween := create_tween()
	stew_tween.tween_property(stew_model, "global_position", stew_target.global_position, cooking_speed)
	stew_tween.finished.connect(_finish_cooking)
	var pot_bottom_tween := create_tween()
	pot_bottom_tween.tween_property(pot_collider_bottom, "global_position", pot_collider_bottom_target.global_position, cooking_speed)

func set_stove_cooking() -> bool:
	var foods := _get_foods_for_cooking()
	if not foods:
		cooking_finished.emit(false)
		return false

	for food: RigidBody3D in foods:
		food.set_cooking(true)
	var food_res: Array[FoodItemData]
	food_res.assign(foods.map(func(f: Node3D) -> FoodItemData: return f.food_resource))
	cook_food.emit(food_res)
	
	_set_collider_cooking(true)
	raise_stew_level()
	return true

func _finish_cooking() -> void:
	pot_collider_bottom.get_child(0).disabled = true
	cooking_finished.emit(true)

func _get_foods_for_cooking() -> Array:
	var nodes := food_detector.get_overlapping_bodies()
	print(nodes)
	var foods := nodes.filter(func(f: Node3D) -> bool: return f.is_in_group(&"Food"))
	return foods

func reset() -> void:
	stew_model.global_position = stew_start
	pot_collider_bottom.global_position = col_bottom_start
	_set_collider_cooking(false)

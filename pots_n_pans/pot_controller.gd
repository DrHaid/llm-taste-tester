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

@export var cooking_speed: float = 1

var col_bottom_start: Vector3 = Vector3.ZERO
var stew_start: Vector3 = Vector3.ZERO

var is_cooking: float = 0
var cooking_progress: float = 0

func _ready() -> void:
	col_bottom_start = pot_collider_bottom.global_position
	stew_start = stew_model.global_position

func _process(delta: float) -> void:
	if is_cooking:
		cooking_progress += delta * cooking_speed
		pot_collider_bottom.global_position = lerp(col_bottom_start, pot_collider_bottom_target.global_position, cooking_progress)
		stew_model.global_position = lerp(stew_start, stew_target.global_position, cooking_progress)
		if cooking_progress >= 1:
			_finish_cooking()

func _set_collider_cooking(cooking: bool) -> void:
	stew_model.visible = cooking
	pot_collider.get_child(0).disabled = cooking
	pot_collider_no_bottom.get_child(0).disabled = not cooking
	pot_collider_bottom.get_child(0).disabled = not cooking

func set_stove_cooking() -> bool:
	var foods := _get_foods_for_cooking()
	if not foods:
		cooking_finished.emit(false)
		return false

	is_cooking = true
	for food: RigidBody3D in foods:
		food.set_cooking(true)
	var food_res: Array[FoodItemData]
	food_res.assign(foods.map(func(f: Node3D) -> FoodItemData: return f.food_resource))
	cook_food.emit(food_res)
	_set_collider_cooking(is_cooking)
	return true

func _finish_cooking() -> void:
	is_cooking = false
	pot_collider_bottom.get_child(0).disabled = true
	cooking_finished.emit(true)

func _get_foods_for_cooking() -> Array:
	var nodes := food_detector.get_overlapping_bodies()
	var foods := nodes.filter(func(f: Node3D) -> bool: return f.is_in_group(&"Food"))
	return foods

func reset() -> void:
	stew_model.global_position = stew_start
	pot_collider_bottom.global_position = col_bottom_start
	cooking_progress = 0
	_set_collider_cooking(false)

extends Node3D

signal cook_food(foods: Array[FoodItemData], spices: Array[String])
signal cooking_finished(successful: bool)

@onready var pot_collider: StaticBody3D = $PotCollider
@onready var pot_collider_no_bottom: StaticBody3D = $PotColliderNoBottom
@onready var pot_collider_bottom: RigidBody3D = $PotColliderBottom
@onready var pot_collider_bottom_target: Marker3D = $PotColliderBottomTarget
@onready var stew_model: Node3D = $StewModel
@onready var stew_target: Marker3D = $StewTarget
@onready var food_detector: Area3D = $FoodDetector

@export var cooking_speed: float = 2
@export var food_stew_level_threshold: int = 4

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

func raise_stew_level(height: float = 1) -> void:
	var stew_target_pos := stew_start + (stew_target.global_position - stew_start) * height
	var stew_tween := create_tween()
	stew_tween.tween_property(stew_model, "global_position", stew_target_pos, cooking_speed)
	stew_tween.finished.connect(_finish_cooking)
	var pot_bottom_tween := create_tween()
	pot_bottom_tween.tween_property(pot_collider_bottom, "global_position", pot_collider_bottom_target.global_position, cooking_speed)

func set_stove_cooking() -> bool:
	var pot_contents := food_detector.get_overlapping_bodies()
	var foods := _get_foods_for_cooking(pot_contents)
	var spices := _get_spices_for_cooking(pot_contents)
	if not foods:
		cooking_finished.emit(false)
		return false

	for food: Food in foods:
		food.set_cooking(true)
	var food_res: Array[FoodItemData]
	food_res.assign(foods.map(func(f: Food) -> FoodItemData: return f.food_resource))

	for spice: Spice in spices:
		spice.set_cooking()
	var spice_names: Array[String]
	spice_names.assign(spices.map(func(s: Spice) -> String: return s.spice_name))

	cook_food.emit(food_res, spice_names)
	_set_collider_cooking(true)

	var stew_level := clampf(float(foods.size()) / float(food_stew_level_threshold), 0, 1)
	raise_stew_level(stew_level)
	return true

func _finish_cooking() -> void:
	pot_collider_bottom.get_child(0).disabled = true
	cooking_finished.emit(true)

func _get_foods_for_cooking(nodes: Array[Node3D]) -> Array[Food]:
	var foods: Array[Food]
	foods.assign(nodes.filter(func(f: Node3D) -> bool: return f.is_in_group(&"Food")))
	return foods

func _get_spices_for_cooking(nodes: Array[Node3D]) -> Array[Spice]:
	var spices: Array[Spice]
	spices.assign(nodes.filter(func(s: Node3D) -> bool: return s.is_in_group(&"Spice")))
	return spices

func reset() -> void:
	stew_model.global_position = stew_start
	pot_collider_bottom.global_position = col_bottom_start
	_set_collider_cooking(false)

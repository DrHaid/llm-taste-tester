class_name  Food
extends RigidBody3D

@export var food_resource: FoodItemData

var drag_food_target: Marker3D = null
var is_cooking: bool = false

var original_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	var food_drag_handler := get_tree().current_scene.get_node("%FoodDragHandler")
	food_drag_handler.connect("start_drag", _on_start_drag)
	food_drag_handler.connect("end_drag", _on_end_drag)
	original_position = global_position

func _process(_delta: float) -> void:
	if drag_food_target:
		global_position = drag_food_target.global_position

	if is_cooking:
		if global_position.y < Globals.Y_LEVEL_KILLZONE:
			reset_food()

func _on_start_drag(dragged_object: Node3D, drag_target: Marker3D) -> void:
	if dragged_object == self:
		drag_food_target = drag_target
		freeze = true

func _on_end_drag(dragged_object: Node3D) -> void:
	if dragged_object == self:
		drag_food_target = null
		freeze = false

func set_cooking(cooking: bool) -> void:
	is_cooking = cooking
	can_sleep = not is_cooking #HACK: necessary for some reason or rigidbody will fall asleep while moving?
	set_collision_mask_value(1, not is_cooking)
	set_collision_mask_value(3, is_cooking)

func reset_food() -> void:
	set_cooking(false)
	global_position = original_position
	linear_velocity = Vector3.ZERO

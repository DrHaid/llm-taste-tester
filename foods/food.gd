class_name  Food
extends RigidBody3D

@export var food_resource: FoodItemData

var drag_food_target: Marker3D = null
var is_cooking: bool = false

var original_position: Vector3 = Vector3.ZERO
var original_scale: Vector3 = Vector3.ZERO

func _ready() -> void:
	can_sleep = false
	var food_drag_handler := get_tree().current_scene.get_node("%FoodDragHandler")
	food_drag_handler.connect("start_drag", _on_start_drag)
	food_drag_handler.connect("end_drag", _on_end_drag)
	original_position = global_position
	original_scale = scale

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

func set_cooking(cooking: bool, speed: int = 0) -> void:
	is_cooking = cooking
	if cooking:
		var stew_tween := create_tween()
		stew_tween.tween_property(self, "scale", Vector3.ZERO, speed) # TODO: tweening scale here not enough, also tween scale of collider
		stew_tween.finished.connect(reset_food)

func reset_food() -> void:
	set_cooking(false)
	scale = original_scale
	global_position = original_position
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

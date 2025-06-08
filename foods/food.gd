class_name  Food
extends RigidBody3D

@export var food_resource: FoodItemData
@export var container_rotation: Vector3 = Vector3(-2, -1, -2)

var drag_food_target: Marker3D = null
var is_cooking: bool = false

var original_position: Vector3 = Vector3.ZERO

var spice_particles: SpiceParticles

func _ready() -> void:
	assert(is_in_group(&"Food"), "Food item not in 'Food' group")

	var food_drag_handler := get_tree().current_scene.get_node("%FoodDragHandler")
	food_drag_handler.connect("start_drag", _on_start_drag)
	food_drag_handler.connect("end_drag", _on_end_drag)
	original_position = global_position
	if food_resource.container:
		init_particles()

func _process(_delta: float) -> void:
	if drag_food_target:
		global_position = drag_food_target.global_position
		if food_resource.container:
			_point_up_toward(Vector3.ZERO)

	if is_cooking:
		if global_position.y < Globals.Y_LEVEL_KILLZONE:
			reset_food()

func _on_start_drag(dragged_object: Node3D, drag_target: Marker3D) -> void:
	if dragged_object == self:
		drag_food_target = drag_target
		freeze = true
		if food_resource.container:
			spice_particles.pour(true)

func _on_end_drag(dragged_object: Node3D) -> void:
	if dragged_object == self:
		drag_food_target = null
		freeze = false
		if food_resource.container:
			spice_particles.pour(false)

func set_cooking(cooking: bool) -> void:
	is_cooking = cooking
	set_collision_mask_value(1, not is_cooking)
	set_collision_mask_value(3, is_cooking)

func reset_food() -> void:
	set_cooking(false)
	global_position = original_position
	linear_velocity = Vector3.ZERO

func _point_up_toward(target_position: Vector3) -> void:
	var to_target := (target_position - global_transform.origin).normalized()
	var up: = to_target
	var arbitrary_forward := Vector3.FORWARD
	if abs(up.dot(arbitrary_forward)) > 0.99:
		arbitrary_forward = Vector3.RIGHT
	var right := up.cross(arbitrary_forward).normalized()
	var forward := right.cross(up).normalized()
	var new_basis := Basis(right, up, forward)
	global_transform.basis = new_basis

func init_particles() -> void:
	spice_particles = $SpiceParticles
	spice_particles.init_spice(food_resource)

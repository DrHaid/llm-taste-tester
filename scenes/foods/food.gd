class_name  Food
extends RigidBody3D

@export var food_resource: FoodItemData
@export var container_rotation: Vector3 = Vector3(-2, -1, -2)
@export var drag_speed: float = 20
@export var rotation_speed: float = 20

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
		var direction := drag_food_target.global_position - global_position
		linear_velocity = direction * drag_speed

		if food_resource.container:
			_point_up_toward(Vector3.ZERO)

	if is_cooking:
		if global_position.y < Globals.Y_LEVEL_KILLZONE:
			reset_food()

func _on_start_drag(dragged_object: Node3D, drag_target: Marker3D) -> void:
	if dragged_object == self:
		drag_food_target = drag_target
		linear_damp = 10
		angular_damp = 10
		if food_resource.container:
			spice_particles.pour(true)

func _on_end_drag(dragged_object: Node3D) -> void:
	if dragged_object == self:
		drag_food_target = null
		linear_damp = 0
		angular_damp = 0
		if food_resource.container:
			spice_particles.pour(false)

func set_cooking(cooking: bool) -> void:
	is_cooking = cooking
	set_collision_mask_value(1, not is_cooking)	# turn off main collision
	set_collision_mask_value(3, is_cooking)	# turn on pot (bottom) collision

func reset_food() -> void:
	set_cooking(false)
	global_position = original_position
	linear_velocity = Vector3.ZERO

func _point_up_toward(target_position: Vector3) -> void:
	var current_up := global_transform.basis.y
	var target_up := (target_position - global_position).normalized()
	var rotation_axis := current_up.cross(target_up)
	angular_velocity = rotation_axis * rotation_speed

func init_particles() -> void:
	spice_particles = $SpiceParticles
	spice_particles.init_spice(food_resource)

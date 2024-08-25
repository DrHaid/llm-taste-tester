extends Node3D

signal start_drag(obj: Node3D, target: Marker3D)
signal end_drag(obj: Node3D)

@onready var pot_rim_elevation: Marker3D = $PotRimElevation
@onready var drag_food_target: Marker3D = $DragFoodTarget

@export_category("Drag elevation")
@export var min_food_elevation: float = 0.15
@export var max_elevation_falloff: float = 1

@export_category("Drag stats")
@export var drag_sensitivity: float = 0.007
@export var drag_value: float = 10
@export var drag_y_value: float = 20

var dragged_object: Node3D = null
var mouse_position: Vector2 = Vector2.ZERO
var raw_target_position: Vector3 = Vector3.ZERO # temporary unsmoothed target position

const RAY_LENGTH: int = 10000

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event)
			else:
				_end_drag()
				
	if event is InputEventMouseMotion:
		mouse_position = event.position

func _process(delta: float) -> void:
	if dragged_object:
		_update_raw_drag_target()
		_set_smoothed_target_pos(delta)

func _start_drag(event: InputEvent) -> void:
	var result := cast_viewport_ray(event.position)
	
	if result and result.collider and result.collider.is_in_group(&"Food"):
		dragged_object = result.collider
		raw_target_position = dragged_object.global_position
		drag_food_target.global_position = raw_target_position
		start_drag.emit(dragged_object, drag_food_target)
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)

func _end_drag() -> void:
	if dragged_object:
		end_drag.emit(dragged_object)
		dragged_object = null
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

func _update_raw_drag_target() -> void:
	# only raycast on layer 2 (surface plane)
	var result := cast_viewport_ray(mouse_position, 0b00000000_00000000_00000000_00000010)
	if result:
		raw_target_position = result.position

func _set_smoothed_target_pos(delta: float) -> void:
	var pos: Vector3 = lerp(drag_food_target.global_position, raw_target_position, delta * drag_value)
	pos.y = lerp(drag_food_target.global_position.y, get_target_elevation(pos), delta * drag_y_value)
	drag_food_target.global_position = pos

func cast_viewport_ray(pos: Vector2, mask: int = 1) -> Dictionary:
	var camera := get_viewport().get_camera_3d()
	var ray_origin := camera.project_ray_origin(pos)
	var ray_direction := camera.project_ray_normal(pos)
	
	var ray_query := PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * RAY_LENGTH, mask)
	var space_state := get_world_3d().direct_space_state
	return space_state.intersect_ray(ray_query)

func get_target_elevation(pos: Vector3) -> float:
	var dist_to_pot := (Vector2(pos.x, pos.z) - Vector2(pot_rim_elevation.global_position.x, pot_rim_elevation.global_position.z)).length()
	var mapped_distance := remap(dist_to_pot, pot_rim_elevation.gizmo_extents, max_elevation_falloff, 0, 1)
	var eased_value := ease_sine(clamp(mapped_distance, 0, 1))
	var elevation: float = lerp(pot_rim_elevation.global_position.y, min_food_elevation, eased_value)
	return elevation

func ease_sine(x: float) -> float: 
	return -(cos(PI * x) - 1) / 2;

extends Node3D
class_name MouseInputHandler

signal start_drag(obj: Node3D, target: Marker3D)
signal end_drag(obj: Node3D)
signal food_hover(name: String)

@onready var pot_rim_elevation: Marker3D = $PotRimElevation
@onready var drag_food_target: Marker3D = $DragFoodTarget
@onready var drag_border: Area3D = $Boundary
@onready var elevation_shape_cast: ShapeCast3D = $ElevationShapeCast3D
@onready var view_collision_boundary: Node3D = %ViewCollisionBoundary

@export_category("Drag elevation")
@export var min_food_elevation: float = 0.15
@export var max_elevation_falloff: float = 1
@export var food_elevation_curve: Curve

var dragged_object: Node3D = null
var mouse_position: Vector2 = Vector2.ZERO
var raw_target_position: Vector3 = Vector3.ZERO # temporary target position

var dragging_enabled: bool = true

func set_drag_enabled(enabled: bool) -> void:
	dragging_enabled = enabled

func _ready() -> void:
	set_process_input(true)
	view_collision_boundary.connect("collider_ready", elevation_shape_cast.add_exception)

func _input(event: InputEvent) -> void:
	if not dragging_enabled:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event)
			else:
				_end_drag()
				
	if event is InputEventMouseMotion:
		mouse_position = event.position

		if not dragged_object:
			var hovered_food := get_food_at_mouse_pos(mouse_position)
			var hovered_food_name := String(hovered_food.name) if hovered_food else ""
			food_hover.emit(hovered_food_name)

func _process(delta: float) -> void:
	if dragged_object:
		_update_raw_drag_target()
		keep_target_in_boundary()
		_set_final_target_pos(delta)

func get_food_at_mouse_pos(pos: Vector2) -> Node:
	var result := cast_viewport_ray(pos)
	if result and result.collider and result.collider.is_in_group(&"Food"):
		return result.collider
	return null

func _start_drag(event: InputEvent) -> void:
	var food := get_food_at_mouse_pos(event.position)
	if food:
		dragged_object = food
		raw_target_position = dragged_object.global_position
		drag_food_target.global_position = raw_target_position
		start_drag.emit(dragged_object, drag_food_target)
		elevation_shape_cast.add_exception(dragged_object)
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)

func _end_drag() -> void:
	if dragged_object:
		end_drag.emit(dragged_object)
		elevation_shape_cast.remove_exception(dragged_object)
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		dragged_object = null

func _update_raw_drag_target() -> void:
	# only raycast on layer 2 (surface plane)
	var result := cast_viewport_ray(mouse_position, Globals.SURFACE_MASK)
	if result:
		raw_target_position = result.position

func _set_final_target_pos(_delta: float) -> void:
	var pos: Vector3 = raw_target_position
	pos.y = get_target_elevation(pos)
	drag_food_target.global_position = pos

func cast_viewport_ray(pos: Vector2, mask: int = 1) -> Dictionary:
	var camera := get_viewport().get_camera_3d()
	var ray_origin := camera.project_ray_origin(pos)
	var ray_direction := camera.project_ray_normal(pos)
	
	var ray_query := PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * Globals.VIEWPORT_RAY_LENGTH, mask)
	var space_state := get_world_3d().direct_space_state
	return space_state.intersect_ray(ray_query)

func get_target_elevation(pos: Vector3) -> float:
	elevation_shape_cast.global_position = Vector3(pos.x, 3, pos.z)
	var fraction := elevation_shape_cast.get_closest_collision_safe_fraction()
	var center_at_collision := elevation_shape_cast.global_position + elevation_shape_cast.target_position * fraction
	return center_at_collision.y

func cast_boundary_ray(pos: Vector3, dest: Vector3) -> Dictionary:
	var ray_query := PhysicsRayQueryParameters3D.create(pos, dest, Globals.FOOD_DRAG_BOUNDARY_MASK)
	ray_query.collide_with_areas = true
	var space_state := get_world_3d().direct_space_state
	return space_state.intersect_ray(ray_query)
	
func check_if_target_in_boundary() -> bool:
	var point_query := PhysicsPointQueryParameters3D.new()
	point_query.position = raw_target_position
	point_query.collide_with_areas = true
	point_query.collision_mask = Globals.FOOD_DRAG_BOUNDARY_MASK
	var space_state := get_world_3d().direct_space_state
	return len(space_state.intersect_point(point_query)) > 0

func keep_target_in_boundary() -> void:
	if check_if_target_in_boundary():
		return

	var boundary_hit: Dictionary = cast_boundary_ray(raw_target_position, drag_border.global_position)
	if not boundary_hit:
		return

	raw_target_position.z = boundary_hit.position.z
	raw_target_position.x = boundary_hit.position.x
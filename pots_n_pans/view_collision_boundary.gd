extends Node3D

@export var floor_intersection_height: float = 0.05
@export var boundary_height: float = 3

signal collider_ready(collision_object: CollisionObject3D)

func _ready() -> void:
	init_collider()

func init_collider() -> void:
	var screen_size := get_viewport().get_visible_rect().size
	var world_view_corners: Dictionary = {
		"top_left": get_view_floor_intersection(Vector2(0, 0)),
		"top_right": get_view_floor_intersection(Vector2(screen_size.x, 0)),
		"bottom_right": get_view_floor_intersection(Vector2(screen_size.x, screen_size.y)),
		"bottom_left": get_view_floor_intersection(Vector2(0, screen_size.y))
	} 

	# build node structure
	var static_body := StaticBody3D.new()
	add_child(static_body)
	var collision_polygon := CollisionPolygon3D.new()
	static_body.add_child(collision_polygon)

	# set collider properties
	collision_polygon.rotation.x = PI / 2
	collision_polygon.depth = -boundary_height # negative because rotating by 90° technically puts it upside down
	collision_polygon.polygon = get_build_collision_polygon(world_view_corners)
	call_deferred("signal_collider_ready", static_body)

func signal_collider_ready(col: CollisionObject3D) -> void:
	collider_ready.emit(col)

func get_polygon_center(positions: Array) -> Vector2:
	return positions.reduce(
		func(accum: Vector2, pos: Vector2) -> Vector2: 
			return pos + accum, Vector2.ZERO) / positions.size() # determine (approximate) center of polygon

func get_build_collision_polygon(world_view_corners: Dictionary) -> Array:
	var points: Array = world_view_corners.values().map(
		func(pos: Vector3) -> Vector2: 
			return Vector2(pos.x, pos.z))
	points.append(points[0]) # append first point to create a loop

	var hull := points.duplicate()
	hull.reverse() # reverse to build hull counter-clockwise
	
	var center := get_polygon_center(hull)
	hull = hull.map(
		func(pos: Vector2) -> Vector2:
			return pos + (pos - center).normalized() * 2) # move all points away from center by 2

	return points + hull

func get_view_floor_intersection(screen_position: Vector2) -> Vector3:
	var camera := get_viewport().get_camera_3d()
	var ray_origin := camera.project_ray_origin(screen_position)
	var ray_direction := camera.project_ray_normal(screen_position)
	
	var plane := Plane(Vector3.UP, floor_intersection_height)
	var intersection: Variant = plane.intersects_ray(ray_origin, ray_direction)
	
	return intersection if intersection else Vector3.ZERO


extends Node3D

signal dial_set_cooking()

@onready var dial: Node3D = $dial
@onready var flame: CPUParticles3D = $Flame

@export_category("Dial")
@export var dial_start_rotation: float = 0
@export var dial_end_rotation: float = -210
@export var dial_turn_speed: float = 0.65

var reverse_dial: bool = false

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				check_dial_click(event)

func check_dial_click(event: InputEventMouseButton) -> void:
	var result := cast_viewport_ray(event.position)
	if result and result.collider:
		if result.collider.get_parent() == dial:
			turn_dial()

func _on_dial_turn_finished() -> void:
	reverse_dial = not reverse_dial
	flame.emitting = reverse_dial
	if reverse_dial:
		dial_set_cooking.emit()

func turn_dial() -> void:
	var tween := create_tween()
	var target_rotation := dial.rotation
	target_rotation.z = deg_to_rad(dial_start_rotation if reverse_dial else dial_end_rotation)
	tween.tween_property(dial, "rotation", target_rotation, dial_turn_speed).set_trans(Tween.TRANS_SPRING)
	tween.finished.connect(_on_dial_turn_finished)

func cast_viewport_ray(pos: Vector2, mask: int = 1) -> Dictionary:
	var camera := get_viewport().get_camera_3d()
	var ray_origin := camera.project_ray_origin(pos)
	var ray_direction := camera.project_ray_normal(pos)
	
	var ray_query := PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * Globals.VIEWPORT_RAY_LENGTH, mask)
	var space_state := get_world_3d().direct_space_state
	return space_state.intersect_ray(ray_query)

func ease_in_out_back(x: float) -> float:
	const c1: float = 1.70158;
	const c2: float = c1 * 1.525;

	return ((pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2 
		if x < 0.5 
		else (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2)
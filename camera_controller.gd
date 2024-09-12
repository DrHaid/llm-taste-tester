extends Node3D

@export var pan_duration: float = 1.5

@onready var camera: Camera3D = $Camera3D
@onready var start_marker: Marker3D = $StartMarker
@onready var end_marker: Marker3D = $EndMarker

func _ready() -> void:
	start_marker.global_transform = camera.global_transform

func pan_in() -> void:
	var position_tween := create_tween()
	position_tween.tween_property(camera, "global_position", end_marker.global_position, pan_duration)
	var rotation_tween := create_tween()
	rotation_tween.tween_property(camera, "global_rotation", end_marker.global_rotation, pan_duration)
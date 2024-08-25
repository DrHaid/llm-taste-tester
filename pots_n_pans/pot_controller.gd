extends Node3D

@onready var stove: Node3D = %Stove
@onready var pot_collider: StaticBody3D = $PotCollider
@onready var pot_collider_no_bottom: StaticBody3D = $PotColliderNoBottom
@onready var pot_collider_bottom: RigidBody3D = $PotColliderBottom
@onready var pot_collider_bottom_target: Marker3D = $PotColliderBottomTarget
@onready var stew_model: Node3D = $StewModel
@onready var stew_target: Marker3D = $StewTarget

@export var cooking_speed: float = 1

var col_bottom_start: Vector3 = Vector3.ZERO
var stew_start: Vector3 = Vector3.ZERO

var is_cooking: float = 0
var cooking_progress: float = 0

func _ready() -> void:
	stove.connect("start_cooking", _on_stove_start_cooking)
	col_bottom_start = pot_collider_bottom.global_position
	stew_start = stew_model.global_position

func _process(delta: float) -> void:
	if is_cooking:
		cooking_progress += delta * cooking_speed
		pot_collider_bottom.global_position = lerp(col_bottom_start, pot_collider_bottom_target.global_position, cooking_progress)
		stew_model.global_position = lerp(stew_start, stew_target.global_position, cooking_progress)
		if cooking_progress >= 1:
			is_cooking = false
			pot_collider_bottom.get_child(0).disabled = false

func _set_collider_cooking(cooking: bool) -> void:
	stew_model.visible = cooking
	pot_collider.get_child(0).disabled = cooking
	pot_collider_no_bottom.get_child(0).disabled = not cooking
	pot_collider_bottom.get_child(0).disabled = not cooking

func start_cooking() -> void:
	is_cooking = true
	_set_collider_cooking(is_cooking)

func reset() -> void:
	stew_model.global_position = stew_start
	pot_collider_bottom.global_position = col_bottom_start
	cooking_progress = 0
	_set_collider_cooking(false)

func _on_stove_start_cooking() -> void:
	start_cooking()

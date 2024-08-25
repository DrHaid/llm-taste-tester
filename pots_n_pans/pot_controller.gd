extends Node3D

@onready var pot_collider: StaticBody3D = $PotCollider
@onready var pot_collider_no_bottom: StaticBody3D = $PotColliderNoBottom
@onready var pot_collider_bottom: RigidBody3D = $PotColliderBottom

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func set_collider_cooking(is_cooking: bool) -> void:
	pot_collider.visible = not is_cooking
	pot_collider_no_bottom.visible = is_cooking
	pot_collider_bottom.visible = is_cooking
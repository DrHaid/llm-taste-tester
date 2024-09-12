extends Node3D

signal spoon_fed()

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.connect("animation_finished", _on_animation_player_animation_finished)	

func play_animation() -> void:
	animation_player.stop()
	animation_player.play("spoon_feed")

func _on_animation_player_animation_finished(_name: String) -> void:
	spoon_fed.emit()
	print("jajaja")


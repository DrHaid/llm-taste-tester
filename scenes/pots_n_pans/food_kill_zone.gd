extends Area3D


func _ready() -> void:
	connect("body_entered", body_entered_kill_zone)


func body_entered_kill_zone(node: Node3D) -> void:
	if node.is_in_group(&"Food"):
		node.reset_food()
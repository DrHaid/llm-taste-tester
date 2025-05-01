extends Node3D

@export_dir var foods_path: String = ""
@export var spawn_radius: float = 0.2
@export var food_scale: float = 0.4

func _ready() -> void:
	var food_scenes := Utils.get_files_in_dir(foods_path)
	var spawns := get_children()
	for food in food_scenes:
		var res := load("%s/%s" % [foods_path, food])
		var instance: Node3D = res.instantiate()
		
		var spawn: Marker3D = spawns.pick_random()
		var spawn_position: Vector3 = spawn.global_position + Vector3(1, 0, 1) * randf_range(-spawn_radius, spawn_radius)
		instance.transform.origin = spawn_position
		instance.scale = Vector3.ONE * food_scale

		get_tree().current_scene.add_child.call_deferred(instance)

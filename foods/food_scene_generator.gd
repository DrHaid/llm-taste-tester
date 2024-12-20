extends Node3D

## Utility script for generating foods scenes to be used in-game out of food resources  

@export var foods: Array[FoodItemData] = []
@export var model_scale: float = 0.6
@export_dir var output_path: String = ""

func _ready() -> void:
	for food in foods:
		generate_food(food)

func generate_food(food: FoodItemData) -> void:
	print("Generating: %s" % food.name)
	# add main rigidbody and settings 
	var food_rigidbody := RigidBody3D.new()
	food_rigidbody.set_name(food.name)
	food_rigidbody.set_freeze_mode(RigidBody3D.FREEZE_MODE_KINEMATIC)
	food_rigidbody.add_to_group(&"Food")
	food_rigidbody.set_script(Food)
	food_rigidbody.food_resource = food

	# add model and collision
	var imported_fbx := load(food.model)
	var meshes := get_meshes(imported_fbx)
	for mesh in meshes:
		_reparent(mesh, food_rigidbody)
		# create static body collision shape
		mesh.scale = Vector3.ONE * model_scale
		mesh.create_convex_collision()
		var static_child := mesh.get_child(0)
		var collision_shape := static_child.get_child(0)
		# make collision shape child of rigidbody
		_reparent(collision_shape, food_rigidbody)
		collision_shape.scale = Vector3.ONE * model_scale
		# exclude static body from being saved
		static_child.owner = null

	save_node(food_rigidbody, food.name.to_lower().replace(" ", "_"))
	print("Saved: %s" % food.name)
	get_tree().quit()


func get_meshes(packed_scene: PackedScene) -> Array[MeshInstance3D]:
	var main_node: Node = packed_scene.instantiate()
	var meshes: Array[MeshInstance3D] = []
	for child in main_node.get_children():
		if is_instance_of(child, MeshInstance3D):
			meshes.append(child)
	return meshes


func save_node(node: Node3D, scene_name: String) -> void:
	var scene := PackedScene.new()
	scene.pack(node)
	var path := "%s/%s.tscn" % [output_path, scene_name]
	ResourceSaver.save(scene, path)


func _reparent(child: Node3D, parent: Node3D) -> void:
		child.owner = null
		child.reparent(parent)
		child.owner = parent
extends Node3D

## Utility script for generating foods scenes to be used in-game out of food resources  

@export_dir var foods_resource_path: String = ""
@export_dir var output_path: String = ""

func _ready() -> void:
	var resource_files := Utils.get_files_in_dir(foods_resource_path)
	for file in resource_files:
		var path := "%s/%s" % [foods_resource_path, file] 
		var food: FoodItemData = load(path)
		generate_food(food)

func generate_food(food: FoodItemData) -> void:
	print("Generating: %s" % food.name)
	# add main rigidbody and settings 
	var food_rigidbody := RigidBody3D.new()
	food_rigidbody.set_name(food.name)
	food_rigidbody.set_freeze_mode(RigidBody3D.FREEZE_MODE_KINEMATIC)
	food_rigidbody.add_to_group(&"Food", true)
	food_rigidbody.set_script(Food)
	food_rigidbody.food_resource = food

	# add model and collision
	var imported_fbx := load(food.model)
	var fbx_instance: Node = imported_fbx.instantiate()
	var meshes := get_and_flatten_meshes(fbx_instance)
	for mesh in meshes:
		_reparent(mesh, food_rigidbody)
		# create static body collision shape
		mesh.create_convex_collision()
		var local_position: Vector3 = mesh.position
		var static_child := mesh.get_child(0)
		var collision_shape := static_child.get_child(0)
		collision_shape.set_name("%s_%s" % [mesh.name, "CollisionShape3D"])
		# make collision shape child of rigidbody
		_reparent(collision_shape, food_rigidbody)
		collision_shape.set_position(local_position)
		# exclude static body from being saved
		static_child.owner = null

	save_node(food_rigidbody, food.name.to_lower().replace(" ", "_"))
	print("Saved: %s" % food.name)
	# get_tree().quit()


func get_and_flatten_meshes(parent: Node) -> Array[Node]:
	var meshes := parent.find_children("*", "MeshInstance3D", true)
	for mesh in meshes:
		_reparent(mesh, parent)
	return meshes

func save_node(node: Node3D, scene_name: String) -> void:
	var scene := PackedScene.new()
	scene.pack(node)
	var path := "%s/%s.tscn" % [output_path, scene_name]
	ResourceSaver.save(scene, path)


func _reparent(child: Node3D, parent: Node3D) -> void:
	child.owner = null
	child.reparent(parent, false)
	child.owner = parent
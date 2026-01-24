@tool
extends Node3D

## Utility script for generating foods scenes to be used in-game out of food resources  

@export_dir var foods_resource_path: String = ""
@export_dir var output_path: String = ""

@export var mass_multiplier: float = 10

@export var generate: bool:
	set(_v):
		generate_foods()

func generate_foods() -> void:
	var resource_files := Utils.get_files_in_dir(foods_resource_path)
	for file in resource_files:
		var path := "%s/%s" % [foods_resource_path, file] 
		var food: FoodItemData = load(path)

		if food.container:
			continue

		generate_food(food)

func generate_food(food: FoodItemData) -> void:
	print("Generating: %s" % food.name)
	# add main rigidbody and settings 
	var food_rigidbody := RigidBody3D.new()
	food_rigidbody.set_name(food.name)
	food_rigidbody.set_freeze_mode(RigidBody3D.FREEZE_MODE_KINEMATIC)
	food_rigidbody.set_center_of_mass_mode(RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM)
	food_rigidbody.add_to_group(&"Food", true)
	food_rigidbody.set_script(Food)
	food_rigidbody.can_sleep = false
	food_rigidbody.food_resource = food
	food_rigidbody.set_collision_layer_value(4, true)	# enable ElevationCast layer

	# add model and collision
	var imported_fbx := load(food.model)
	var fbx_instance: Node = imported_fbx.instantiate()
	var mesh := get_main_mesh(fbx_instance)

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

	# determine and set center of mass and mass
	var food_aabb: AABB = AABB(Vector3.ZERO, Vector3.ZERO)
	food_aabb = food_aabb.merge(mesh.get_aabb())

	# offset children so the object origin in at center of mass
	for child in food_rigidbody.get_children():
		child.set_position(child.position - food_aabb.get_center())

	# set mass according to bourdary
	food_rigidbody.set_mass(food_aabb.get_volume() * mass_multiplier)

	save_node(food_rigidbody, food.name.to_lower().replace(" ", "_"))
	print("Saved: %s" % food.name)
	# get_tree().quit()


func get_main_mesh(parent: Node) -> Node:
	var meshes := parent.find_children("*", "MeshInstance3D", true)
	if meshes.size() > 1:
		printerr("'%s'FBX has more than one object, this is not supported".format(parent.name))
	
	var mesh := meshes[0]
	_reparent(mesh, parent)
	return mesh

func save_node(node: Node3D, scene_name: String) -> void:
	var scene := PackedScene.new()
	scene.pack(node)
	var path := "%s/%s.tscn" % [output_path, scene_name]
	ResourceSaver.save(scene, path)


func _reparent(child: Node3D, parent: Node3D) -> void:
	child.owner = null
	child.reparent(parent, false)
	child.owner = parent
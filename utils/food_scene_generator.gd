@tool
extends Node3D

## Utility script for generating foods scenes to be used in-game out of food resources  

@export_dir var foods_resource_path: String = ""
@export_dir var output_path: String = ""

@export var mass_multiplier: float = 10
@export var jolt_scale_multiplier: float = 3

@export var generate: bool:
	set(_v):
		generate_foods()

func generate_foods() -> void:
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

	# assign material
	mesh.set_surface_override_material(0, food.material)

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

	# scale
	var food_scale := food.size * jolt_scale_multiplier
	var food_size := food_scale * Vector3.ONE
	mesh.scale = food_size
	collision_shape.scale = food_size

	# determine and set center of mass and mass
	var mesh_aabb: AABB = mesh.get_aabb()
	var scaled_aabb := AABB(mesh_aabb.position * food_scale, mesh_aabb.size * food_scale)
	var center_offset := scaled_aabb.get_center()

	# offset children so the object origin is at center of mass
	for child in food_rigidbody.get_children():
		child.position = child.position - center_offset

	# set mass according to volume
	food_rigidbody.set_mass(scaled_aabb.get_volume() * mass_multiplier)

	save_node(food_rigidbody, food.name.to_lower().replace(" ", "_"))
	print("Saved: %s" % food.name)
	# get_tree().quit()


func get_main_mesh(parent: Node) -> Node3D:
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
extends Node3D

## Utility script for generating foods resource files from models  

@export_dir var model_path: String = ""
@export_dir var resource_path: String = ""


func _ready() -> void:
	generate_food_resources()


func generate_food_resources() -> void:
	print("Generating resources for models")
	for file in get_files(model_path):
		if file.ends_with(".import"):
			continue
		
		print(file)
		var resource_file_name := file.replace(".fbx", "").replace("-", "_")
		var food_resource := FoodItemData.new()
		food_resource.model = "%s/%s" % [model_path, file]
		
		var path := "%s/%s.tres" % [resource_path, resource_file_name]
		ResourceSaver.save(food_resource, path)


func get_files(directory: String) -> Array[String]:
	var files: Array[String] = []
	var dir := DirAccess.open(directory)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				continue

			files.append(file_name)			
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the directory.")
	
	return files
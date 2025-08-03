@tool
extends Node3D

## Utility script for generating foods resource files from models  

@export_dir var model_path: String = ""
@export_dir var resource_path: String = ""

@export var generate: bool:
	set(_v):
		generate_food_resources()

func generate_food_resources() -> void:
	print("Generating resources for models")

	for file: String in Utils.get_files_in_dir(model_path):
		if file.ends_with(".import"):
			continue
		
		var resource_file_name := file.replace(".fbx", "").replace("-", "_")
		var dest_path := "%s/%s.tres" % [resource_path, resource_file_name]

		if FileAccess.file_exists(dest_path):
			continue

		var food_resource := FoodItemData.new()
		food_resource.model = "%s/%s" % [model_path, file]		
		ResourceSaver.save(food_resource, dest_path)
		print("Saved: " + file)

	print("Done")
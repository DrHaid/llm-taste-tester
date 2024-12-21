extends Node3D

## Utility script for generating foods resource files from models  

@export_dir var model_path: String = ""
@export_dir var resource_path: String = ""


func _ready() -> void:
	generate_food_resources()


func generate_food_resources() -> void:
	print("Generating resources for models")
	for file in Utils.get_files_in_dir(model_path):
		if file.ends_with(".import"):
			continue
		
		print(file)
		var resource_file_name := file.replace(".fbx", "").replace("-", "_")
		var food_resource := FoodItemData.new()
		food_resource.model = "%s/%s" % [model_path, file]
		
		var path := "%s/%s.tres" % [resource_path, resource_file_name]
		ResourceSaver.save(food_resource, path)
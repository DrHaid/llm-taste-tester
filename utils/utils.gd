extends Node

func get_files_in_dir(directory: String) -> Array[String]:
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


func distinct_entries(array: Array) -> Array:
	var unique: Array = []
	for item: Variant in array:
		if not unique.has(item):
			unique.append(item)
	return unique
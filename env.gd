extends Node

var env: Dictionary = {}

func _ready() -> void:
	env = _read_env("res://.env")

func get_var(key: String) -> String:
	var os_var := OS.get_environment(key)
	if os_var:
		return os_var

	var env_var: Variant = env.get(key)
	if env_var:
		return env_var
	return ""


func _read_env(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	
	var file := FileAccess.open(path, FileAccess.READ)
	var lines: Array[String] = []
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()

	var envs: Dictionary = {}
	for line in lines:
		var entry := line.split("=")
		envs[entry[0]] = entry[1]
	
	return envs

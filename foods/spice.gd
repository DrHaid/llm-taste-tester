class_name Spice
extends RigidBody3D

signal delete_particle(spice: Spice)

@export var delete_delay: float = 2
@export var spice_name: String

var timer := Timer.new()

func _ready() -> void:
	assert(is_in_group(&"Spice"), "Spice particle not in 'Spice' group")

func init_particle(spice: String, pos: Vector3, material: Material) -> void:
	spice_name = spice
	global_position = pos
	var mesh := get_child(0) as MeshInstance3D
	mesh.set_surface_override_material(0, material)

	# init delete timer
	add_child(timer)
	timer.wait_time = delete_delay
	timer.connect("timeout", on_delete_timeout)
	timer.start()
	timer.paused = true

func set_cooking() -> void:
	timer.paused = false

func on_delete_timeout() -> void:
	print("timeout")
	delete_particle.emit(self)
	queue_free.call_deferred()
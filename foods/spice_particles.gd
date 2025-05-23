extends Marker3D
class_name SpiceParticles

@export var speed: float = 0.2
@onready var particle: Resource = load("res://foods/spice.tscn") 

var spice: String
var spice_color: Color
var spawn_timer: Timer = Timer.new()

var particles: Array = []

func pour(pouring: bool) -> void:
	spawn_timer.paused = not pouring

func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.wait_time = speed
	spawn_timer.connect("timeout", _on_spawn_timout)
	spawn_timer.start()
	spawn_timer.paused = true

func _on_spawn_timout() -> void:
	if particles.size() > 15:
		var old: Node3D = particles.pop_at(0)
		old.queue_free()

	var spice_particle: RigidBody3D = particle.instantiate()
	get_tree().current_scene.add_child(spice_particle)
	spice_particle.global_position = global_position
	spice_particle.set_meta(&"spice", spice)
	var mesh := spice_particle.get_child(0) as MeshInstance3D
	mesh.get_surface_override_material(0).albedo_color = spice_color
	particles.append(spice_particle)

func init_spice(food_resource: FoodItemData) -> void:
	spice = food_resource.spice
	spice_color = food_resource.spice_color

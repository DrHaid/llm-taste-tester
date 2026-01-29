extends Marker3D
class_name SpiceParticles

@export var speed: float = 0.2
@export var material: StandardMaterial3D
@onready var particle: Resource = load("res://scenes/foods/spice.tscn") 

const MAX_PARTICLES = 15 

var spice_name: String
var spawn_timer: Timer = Timer.new()

var particles: Array[Spice] = []

func pour(pouring: bool) -> void:
	spawn_timer.paused = not pouring

func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.wait_time = speed
	spawn_timer.connect("timeout", _on_spawn_timout)
	spawn_timer.start()
	spawn_timer.paused = true

func _on_spawn_timout() -> void:
	if particles.size() > MAX_PARTICLES:
		var old: Spice = particles.pop_at(0)
		old.queue_free()

	var spice_particle: Spice = particle.instantiate()
	get_tree().current_scene.add_child(spice_particle)
	spice_particle.init_particle(spice_name, global_position, material)
	spice_particle.connect("delete_particle", on_spice_particle_delete)
	particles.append(spice_particle)

func on_spice_particle_delete(spice: Spice) -> void:
	# remove spice from particles
	var index := particles.find(spice)
	if index >= 0:
		particles.remove_at(index)

func init_spice(food_resource: FoodItemData) -> void:
	spice_name = food_resource.spice
	material = StandardMaterial3D.new()
	material.albedo_color = food_resource.spice_color
	material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
extends Control

@onready var reset_button: TextureButton = $ResetButton 
@onready var help_text_container: PanelContainer = $MarginContainer/HelpTextContainer
@onready var food_label: Label = $MarginContainer/FoodLabel

func _ready() -> void:
	set_process_input(true)
	var mouse_input_handler := %FoodDragHandler
	mouse_input_handler.connect("food_hover", update_food_label)
	reset_button.connect("pressed", reset_scene)
	_setup_button_textures()

func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		reset_scene()

func get_darkened_texture(texture: Texture2D, brightness: float) -> Texture2D:
	var image := texture.get_image()
	image.adjust_bcs(brightness, 1, 1)
	return ImageTexture.create_from_image(image)

func _setup_button_textures() -> void:
	var normal_texture := reset_button.texture_normal
	reset_button.texture_hover = get_darkened_texture(normal_texture, 0.85)
	reset_button.texture_pressed = get_darkened_texture(normal_texture, 0.6)

func reset_scene() -> void:
	get_tree().reload_current_scene()

func show_help(show_container: bool) -> void:
	help_text_container.visible = show_container

func update_food_label(food: String = "") -> void:
	if food == "":
		food_label.visible = false
		return

	food_label.visible = true
	food_label.text = food

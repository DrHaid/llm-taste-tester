extends Control

@onready var help_text_container: PanelContainer = $MarginContainer/HelpTextContainer
@onready var food_label: Label = $MarginContainer/FoodLabel

func _ready() -> void:
	var mouse_input_handler := %FoodDragHandler
	mouse_input_handler.connect("food_hover", update_food_label)

func show_help(show_container: bool) -> void:
	help_text_container.visible = show_container

func update_food_label(food: String = "") -> void:
	if food == "":
		food_label.visible = false
		return

	food_label.visible = true
	food_label.text = food
	



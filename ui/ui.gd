extends Control

@onready var help_text_container: PanelContainer = %HelpTextContainer
@onready var food_label: Label = %FoodLabel

func _ready() -> void:
	pass # Replace with function body.

func show_help(show_container: bool) -> void:
	help_text_container.visible = show_container

func update_food_label(food: String = "") -> void:
	if food == "":
		food_label.visible = false
		return

	food_label.visible = true
	food_label.text = food
	



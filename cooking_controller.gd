extends Node

@onready var ui: Control = %UI
@onready var camera_rig: Node3D = %CameraRig
@onready var stove: Node3D = %Stove
@onready var pot: Node3D = %Pot
@onready var food_drag_handler: Node3D = %FoodDragHandler
@onready var tasting_spoon: Node3D = %TastingSpoon
@onready var eating_robot: Node3D = %EatingRobot

var current_foods: Array[FoodItemData] = []

func _ready() -> void:
	stove.connect("dial_set_cooking", _on_stove_dial_set_cooking)
	pot.connect("cook_food", _on_pot_cook_food)
	pot.connect("cooking_finished", _on_pot_cooking_finished)
	tasting_spoon.connect("spoon_fed", _on_tasting_spoon_spoon_fed)
	camera_rig.connect("pan_complete", _on_camera_rig_pan_complete)

func _on_stove_dial_set_cooking() -> void:
	if pot.set_stove_cooking():
		food_drag_handler.set_drag_enabled(false)

func _on_pot_cook_food(foods: Array[FoodItemData]) -> void:
	current_foods = foods

func _on_pot_cooking_finished(successful: bool) -> void:
	stove.turn_dial()
	if successful:
		tasting_spoon.play_animation()

func _on_tasting_spoon_spoon_fed() -> void:
	camera_rig.pan_in()

func _on_camera_rig_pan_complete() -> void:
	eating_robot.start_tasting(current_foods)
	ui.show_help(true)

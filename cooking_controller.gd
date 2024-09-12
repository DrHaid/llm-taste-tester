extends Node

@onready var stove: Node3D = %Stove
@onready var pot: Node3D = %Pot
@onready var food_drag_handler: Node3D = %FoodDragHandler
@onready var tasting_spoon: Node3D = %TastingSpoon

var current_foods: Array[FoodItemData] = []

func _ready() -> void:
	stove.connect("dial_set_cooking", _on_stove_dial_set_cooking)
	pot.connect("cook_food", _on_pot_cook_food)
	pot.connect("cooking_finished", _on_pot_cooking_finished)

func _on_stove_dial_set_cooking() -> void:
	pot.set_stove_cooking()
	food_drag_handler.set_drag_enabled(false)

func _on_pot_cook_food(foods: Array[FoodItemData]) -> void:
	current_foods = foods

func _on_pot_cooking_finished() -> void:
	stove.turn_dial()
	tasting_spoon.play_animation()

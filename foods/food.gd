extends RigidBody3D

@export var food_resource: FoodItemData

@onready var food_drag_handler: Node3D = $"../FoodDragHandler"

var drag_food_target: Marker3D = null

func _ready() -> void:
	food_drag_handler.connect("start_drag", _on_start_drag)
	food_drag_handler.connect("end_drag", _on_end_drag)

func _process(_delta: float) -> void:
	if drag_food_target:
		global_position = drag_food_target.global_position

func _on_start_drag(dragged_object: Node3D, drag_target: Marker3D) -> void:
	if dragged_object == self:
		drag_food_target = drag_target
		freeze = true

func _on_end_drag(dragged_object: Node3D) -> void:
	if dragged_object == self:
		drag_food_target = null
		freeze = false

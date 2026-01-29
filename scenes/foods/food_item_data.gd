extends Resource
class_name FoodItemData

@export var name: String
@export_file var model: String
@export var material: Material = preload("res://models/materials/colormap.material")
@export var size: float = 1
@export var container: bool
@export var spice: String
@export var spice_color: Color

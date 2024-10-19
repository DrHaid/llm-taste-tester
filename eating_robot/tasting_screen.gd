extends Node3D

@export var face_frames: PackedStringArray = ["<(°-°)>", "<(°~°)>", "<(°O°)>"] 
@export var tasting_frames: PackedStringArray = ["tasting food", "tasting food.", "tasting food..", "tasting food..."] 
@export var text_speed: float = 5

@onready var face_text: Label3D = $FaceText
@onready var tasting_text: Label3D = $TastingText

var is_tasting: bool = false
var text_cycle_progress: float = 0

func _process(delta: float) -> void:
	if is_tasting:
		text_cycle_progress += delta * text_speed
		face_text.text = face_frames[wrap(text_cycle_progress, 0, face_frames.size())]
		tasting_text.text = tasting_frames[wrap(text_cycle_progress, 0, tasting_frames.size())]

func set_tasting(tasting: bool) -> void:
	if not tasting:
		face_text.text = ""
		tasting_text.text = ""
		is_tasting = false
		return

	is_tasting = true
	text_cycle_progress = 0

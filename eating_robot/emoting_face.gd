extends Label3D
class_name EmotingFace

var faces: FaceCollection

@export var mouth_lowness: int = 2
@export var mouth_speed: float = 7

var current_face: Face
var progress: bool = false
var text_cycle_progress: float = 0

func _ready() -> void:
	faces = load("res://eating_robot/faces.tres")
	current_face = faces.get_by_mood(Face.MOOD.THRILLED)

func _process(delta: float) -> void:
	if progress:
		text_cycle_progress += delta * mouth_speed

	update_face()

func set_face(mood: Face.MOOD) -> void:
	if mood == Face.MOOD.NONE:
		current_face = null
		return

	var face := faces.get_by_mood(mood)
	progress = (face.min_time == 0 and face.max_time == 0)
	current_face = face

func update_face() -> void:
	if current_face == null:
		text = ""
		return

	text = build_face_text(current_face.eyes, current_face.mouth, int(text_cycle_progress))

func build_face_text(eyes: Face.EYE_MOOD, mouth: Face.MOUTH_MOOD, mouth_offset: int = 0) -> String:
	var mouth_text: String = Face.MOUTH[mouth]
	var current_mouth_text: String = mouth_text[wrap(mouth_offset, 0, mouth_text.length())]
	mouth_text = ScreenText.SPACE.repeat(mouth_lowness) + current_mouth_text
	var eye_text: String = Face.EYES[eyes]
	var face_text := ScreenText.NEW_LINE.join([eye_text, mouth_text, eye_text])
	return face_text


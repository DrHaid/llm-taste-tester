extends Label3D
class_name EmotingFace

var faces: FaceCollection

@export var mouth_lowness: int = 2
@export var mouth_speed: float = 7

var current_face: Face
# mouth animation
var progress_mouth_text: bool = false
var cycle_progress_mouth_text: float = 0
# face animation
var progress_face: bool = false
var time_until_next_face: float = 0

func _ready() -> void:
	faces = load("res://eating_robot/faces.tres")
	current_face = faces.get_by_mood(Face.MOOD.THRILLED)
	next_face_cycle()

func _process(delta: float) -> void:
	if progress_mouth_text:
		cycle_progress_mouth_text += delta * mouth_speed

	if progress_face:
		if time_until_next_face <= 0:
			next_face_cycle()
		time_until_next_face -= delta

	update_face()

func next_face_cycle() -> void:
	progress_face = true
	var mood := faces.get_random_mood()
	set_face(mood)

func stop_face_cycle() -> void:
	progress_face = false
	time_until_next_face = 0

func set_face(mood: Face.MOOD, permanent: bool = false) -> void:
	if permanent:
		stop_face_cycle()

	if mood == Face.MOOD.NONE:
		current_face = null
		return

	var face := faces.get_by_mood(mood)
	time_until_next_face = randf_range(face.min_time, face.max_time)
	progress_mouth_text = (face.min_time == 0 and face.max_time == 0) #TODO: do better
	current_face = face

func update_face() -> void:
	if current_face == null:
		text = ""
		return

	text = build_face_text(current_face.eyes, current_face.mouth, int(cycle_progress_mouth_text))

func build_face_text(eyes: Face.EYE_MOOD, mouth: Face.MOUTH_MOOD, mouth_offset: int = 0) -> String:
	var mouth_text: String = Face.MOUTH[mouth]
	var current_mouth_text: String = mouth_text[wrap(mouth_offset, 0, mouth_text.length())]
	mouth_text = ScreenText.SPACE.repeat(mouth_lowness) + current_mouth_text
	var eye_text: String = Face.EYES[eyes]
	var face_text := ScreenText.NEW_LINE.join([eye_text, mouth_text, eye_text])
	return face_text


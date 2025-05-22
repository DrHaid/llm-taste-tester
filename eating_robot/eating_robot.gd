extends Node3D
class_name EatingRobot

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var screen_text: Label3D = $ScreenText
@onready var emoting_face: EmotingFace = $body/EmotingFace
@onready var mouse_input_handler: MouseInputHandler = %FoodDragHandler

@onready var robot_body: Node3D = $body

var llm_requester: LLMRequester

var start_orientation: Vector3
var previous_angle: float
var current_food: Node3D

func _ready() -> void:
	start_orientation = global_transform.basis.z
	llm_requester = LLMRequester.new(http_request)
	llm_requester.connect("request_completed", _on_llm_request_completed)
	mouse_input_handler.connect("start_drag", on_food_picked_up)
	mouse_input_handler.connect("end_drag", on_food_released)

func _process(_delta: float) -> void:
	var target_orientation := start_orientation
	if current_food:
		target_orientation = current_food.global_position - robot_body.global_position

	target_orientation.y = 0
	var angle := start_orientation.signed_angle_to(target_orientation, Vector3.UP)
	var rot := robot_body.rotation
	rot.y = lerp_angle(previous_angle, angle, 0.02)
	previous_angle = rot.y
	robot_body.rotation = rot

func on_food_picked_up(food: Node3D, _marker: Marker3D) -> void:
	current_food = food

func on_food_released(_food: Node3D) -> void:
	current_food = null

func start_tasting(food: Array[FoodItemData]) -> void:
	emoting_face.set_face(Face.MOOD.CHEWING, true)
	llm_requester.request_tasting(food)

func _get_url_path(url: String) -> String:
	var url_path := "/"
	var path_start := url.find("/api/")
	if path_start != -1:
		url_path = url.substr(path_start)
	return url_path

func _on_llm_request_completed(response: String) -> void:
	if not response:
		emoting_face.set_face(Face.MOOD.NONE, true)
		screen_text.print_text("Oopsies... Error :(")
		return

	emoting_face.set_face(Face.MOOD.NONE, true)
	screen_text.print_text(response)

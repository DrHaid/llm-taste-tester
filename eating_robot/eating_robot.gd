extends Node3D

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var screen_text: Label3D = $ScreenText
@onready var emoting_face: EmotingFace = $EmotingFace

var llm_requester: LLMRequester

func _ready() -> void:
	llm_requester = LLMRequester.new(http_request)
	llm_requester.connect("request_completed", _on_llm_request_completed)

func start_tasting(food: Array[FoodItemData]) -> void:
	emoting_face.set_face(Face.MOOD.CHEWING)
	llm_requester.request_tasting(food)

func _get_url_path(url: String) -> String:
	var url_path := "/"
	var path_start := url.find("/api/")
	if path_start != -1:
		url_path = url.substr(path_start)
	return url_path

func _on_llm_request_completed(response: String) -> void:
	if not response:
		emoting_face.set_face(Face.MOOD.NONE)
		screen_text.print_text("Oopsies... Error :(")
		return

	emoting_face.set_face(Face.MOOD.NONE)
	screen_text.print_text(response)

extends Node3D

@export_multiline var debug_text: String = ""
@export var print_speed: float = 1

@onready var screen_text: Label3D = $ScreenText

var text_to_print: String = ""
var print_load: float = 0
var is_printing: bool = false

func _ready() -> void:
	print_text(debug_text)

func _process(delta: float) -> void:
	if not is_printing:
		return
	
	if not _do_printing(delta):
		is_printing = false
	
func _do_printing(delta: float) -> bool:
	print_load -= delta * print_speed
	var number_of_chars: = int(text_to_print.length() - print_load)
	var text: String = text_to_print.substr(0, number_of_chars)
	screen_text.text = text
	return print_load > 0


func print_text(text: String) -> void:
	text_to_print = text
	print_load = text_to_print.length()
	is_printing = true
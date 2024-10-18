extends Node3D

@export_multiline var debug_text: String = ""
@export var print_speed: float = 1
@export var max_lines: int = 5

@onready var screen_text: Label3D = $ScreenText

const NEW_LINE: String = "\n"

var text_to_print: String = ""
var line_number: int = 0
var print_load: float = 0
var print_start_index: int = 0
var is_printing: bool = false

func _ready() -> void:
	print_text(debug_text)

func _process(delta: float) -> void:
	if not is_printing:
		return
	
	if not _do_printing(delta):
		is_printing = false
	
func _do_printing(delta: float) -> bool:
	var next_print_load: float = print_load - delta * print_speed
	if floor(next_print_load) != floor(print_load):
		update_screen_text(next_print_load)
	print_load = next_print_load
	return print_load > 0

func get_line_start_index(line: int) -> int:
	if line == 1:
		return 0
	
	var i: int = 0
	for _x in range(line - 1):
		i = text_to_print.find(NEW_LINE, i + 1)
	return i + 1

func update_screen_text(new_print_load: float) -> void:
	var number_of_chars_to_print: = int(text_to_print.length() - new_print_load)
	var next_char: String = text_to_print[number_of_chars_to_print - 1]
	if next_char == NEW_LINE:
		line_number += 1
		if line_number > max_lines:
			print_start_index = get_line_start_index(line_number - max_lines + 1)
	var text: String = text_to_print.substr(print_start_index, number_of_chars_to_print - print_start_index)
	screen_text.text = text


func print_text(text: String) -> void:
	text_to_print = text
	print_load = text_to_print.length()
	line_number = 1
	print_start_index = 0
	is_printing = true
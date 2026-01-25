extends Label3D
class_name ScreenText

@export var print_speed: float = 20
@export var print_speed_fast: float = 40
@export var max_lines: int = 11
@export var max_chars_per_line: int = 22

const NEW_LINE: String = "\n"
const SPACE: String = " "

var current_print_speed := print_speed
var text_to_print: String = ""
var line_number: int = 0
var print_load: float = 0
var print_start_index: int = 0
var is_printing: bool = false
var total_lines: int = 0

func _ready() -> void:
	set_process_input(true)

func _process(delta: float) -> void:
	if not is_printing:
		return
	
	if not _do_printing(delta):
		is_printing = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			current_print_speed = print_speed_fast if event.pressed else print_speed
		
		# Handle mouse wheel scrolling when printing is finished
		elif not is_printing and total_lines > max_lines and event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and print_start_index > 0:
				# Scroll up
				var prev_line := _get_previous_line() + 1
				if prev_line >= 0:
					print_start_index = prev_line
					line_number -= 1
					update_text_scroll_position()
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				# Scroll down
				var next_line := _get_next_line()
				if next_line < text_to_print.length() and line_number < total_lines:
					print_start_index = next_line
					line_number += 1
					update_text_scroll_position()

func _do_printing(delta: float) -> bool:
	var next_print_load: float = print_load - delta * current_print_speed
	if floor(next_print_load) != floor(print_load):
		update_screen_text(next_print_load)
	print_load = next_print_load
	return print_load > 0

func _get_line_start_index(line: int) -> int:
	if line == 1:
		return 0
	
	var i: int = 0
	for _x in range(line - 1):
		i = text_to_print.find(NEW_LINE, i + 1)
	return i + 1

func _get_previous_line() -> int:
	if print_start_index == 0:
		return -1
	
	return text_to_print.rfind(NEW_LINE, print_start_index - 2)

func _get_next_line() -> int:
	var next_line_index := text_to_print.find(NEW_LINE, print_start_index)
	if next_line_index == -1:
		return -1
	return next_line_index + 1

func update_text_scroll_position() -> void:
	var screen_text: String = text_to_print.substr(print_start_index)
	var lines := screen_text.split(NEW_LINE).slice(0, max_lines)
	screen_text = NEW_LINE.join(lines)
	text = screen_text

func update_screen_text(new_print_load: float) -> void:
	var number_of_chars_to_print: = int(text_to_print.length() - new_print_load)
	var next_char: String = text_to_print[number_of_chars_to_print - 1]
	if next_char == NEW_LINE:
		line_number += 1
		total_lines = line_number
		if line_number > max_lines:
			print_start_index = _get_line_start_index(line_number - max_lines + 1)
	var screen_text: String = text_to_print.substr(print_start_index, number_of_chars_to_print - print_start_index)
	text = screen_text

func _add_line_breaks(screen_text: String) -> String:
	var lines: PackedStringArray = screen_text.split(NEW_LINE)
	var new_lines: PackedStringArray = []
	for line in lines:
		var i := 0

		var get_line_segment := func(from: int, length: int) -> String:
			return line.substr(from, length).strip_edges()

		while i < line.length():
			var next_pos: int = clamp(i + max_chars_per_line, 0, line.length())
			if next_pos >= line.length():
				# last segment of line, just add rest and break
				new_lines.append(get_line_segment.call(i, line.length() - i))
				break

			# find the last space in the current segment
			var segment := line.substr(i, next_pos - i)
			var space_occurance := segment.rfind(SPACE)
			
			if space_occurance == -1:
				# no space found in current line segment, forcing break with hyphen
				new_lines.append("{0}-".format(line.substr(i, max_chars_per_line - 1).strip_edges()))
				i += max_chars_per_line - 1
				continue

			# add line segment until last space before line character limit
			new_lines.append(get_line_segment.call(i, space_occurance))
			i += space_occurance + 1  # +1 to skip the space
		
	return NEW_LINE.join(new_lines)

func print_text(screen_text: String) -> void:
	text_to_print = _add_line_breaks(screen_text)
	print_load = text_to_print.length()
	line_number = 1
	total_lines = 1
	print_start_index = 0
	is_printing = true
extends Control

@export var typing_timeout: float = 2

@onready var text_label: RichTextLabel = $TypedText

var cursor_timer: Timer = Timer.new()
var cursor_text: String = "" 

var typing_timeout_timer: Timer = Timer.new()
var typing_buffer: String = ""

func _ready() -> void:
	set_process_input(true)

	add_child(cursor_timer)
	cursor_timer.start(0.5)
	cursor_timer.connect("timeout", on_cursor_timer_timeout)

	add_child(typing_timeout_timer)
	typing_timeout_timer.wait_time = typing_timeout
	typing_timeout_timer.connect("timeout", on_typing_timer_timeout)

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		var key := event.as_text()
		if key.length() == 1:
			# probably a letter
			type_letter(key)
		if Input.is_key_pressed(KEY_BACKSPACE):
			if Input.is_key_pressed(KEY_CTRL):
				clear_input()
			else:
				delete_letter()

func _process(_delta: float) -> void:
	text_label.text = typing_buffer if typing_buffer != "" else cursor_text

func type_letter(letter: String) -> void:
	typing_buffer += letter
	typing_timeout_timer.start()

func delete_letter() -> void:
	typing_buffer = typing_buffer.left(-1)
	typing_timeout_timer.start()

func clear_input() -> void:
	typing_buffer = ""
	typing_timeout_timer.stop()

func on_typing_timer_timeout() -> void:
	typing_buffer = ""

func on_cursor_timer_timeout() -> void:
	cursor_text = "_" if cursor_text == "" else ""
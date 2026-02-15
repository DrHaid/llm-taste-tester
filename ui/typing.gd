extends Control

@export var typing_timeout: float = 2

@onready var text_label: RichTextLabel = $TypedText

var cursor_timer: Timer = Timer.new()
var cursor_text: String = "" 

var typing_timeout_timer: Timer = Timer.new()
var typing_buffer: String = ""
var matching_food: Food

var foods_in_scene: Array[Node] = []

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
		if Input.is_key_pressed(KEY_SPACE):
			type_letter(" ")
		if Input.is_key_pressed(KEY_BACKSPACE):
			if Input.is_key_pressed(KEY_CTRL):
				clear_input()
			else:
				delete_letter()
		if Input.is_key_pressed(KEY_TAB):
			typing_buffer = matching_food.food_resource.name.to_upper()
		if Input.is_key_pressed(KEY_ENTER) and matching_food:
			call_deferred("put_matching_food_in_pot", matching_food)
			clear_input()

func _process(_delta: float) -> void:
	text_label.text = get_display_text() if typing_buffer != "" else cursor_text

func type_letter(letter: String) -> void:
	typing_buffer += letter
	typing_timeout_timer.start()
	if foods_in_scene == []:
		init_foods()
	update_search()

func delete_letter() -> void:
	typing_buffer = typing_buffer.left(-1)
	typing_timeout_timer.start()
	update_search()

func clear_input() -> void:
	typing_buffer = ""
	typing_timeout_timer.stop()
	update_search()

func on_typing_timer_timeout() -> void:
	typing_buffer = ""

func on_cursor_timer_timeout() -> void:
	cursor_text = "_" if cursor_text == "" else ""

func init_foods() -> void:
	foods_in_scene = get_tree().get_nodes_in_group(&"Food")

func update_search() -> void:
	if typing_buffer == "":
		matching_food = null
		return

	var matching_foods: Array[Food] = []
	for food: Food in foods_in_scene:
		if food.food_resource.name.to_upper().begins_with(typing_buffer):
			matching_foods.append(food)

	matching_foods.sort()
	matching_food = matching_foods.get(0) if matching_foods.size() > 0 else null

func get_display_text() -> String:
	if !matching_food:
		return typing_buffer

	var matching_food_name := matching_food.food_resource.name.to_upper()
	var suggestion := matching_food_name.substr(typing_buffer.length())
	var styled_suggestion := "%s[color=dark_gray]%s[/color]\n" % [typing_buffer, suggestion]
	return styled_suggestion

func put_matching_food_in_pot(food: Food) -> void:
	food.put_in_da_pot()
extends Node

var cached_value: String = ""

func _ready() -> void:
	var tex: Texture2D = load("res://utils/car.png")
	var img := tex.get_image()
	var val1 := _value1("zoyptwzpzibnz")
	var current_time := Time.get_datetime_dict_from_unix_time(val1)
	var val2 := _value1("what".repeat(current_time.get("weekday")))
	var col := img.get_pixel(val1 % img.get_width(), val2 % img.get_height())
	cached_value = col.to_html().sha256_text()

func _value1(start: String) -> int:
	var v := start.sha256_text().erase(9, 34)
	var w := v.to_int()
	var x := w % 1337
	return x

func _value2(start: String) -> int:
	var chars := start.to_utf8_buffer()
	var combined := 0
	for i in chars.size():
		combined = ((combined << 5) - combined) + chars[i]
	
	var hash_text := str(combined).md5_text()
	var trimmed := hash_text.substr(3, 8)
	var numeric := ("0x" + trimmed).hex_to_int()
	return numeric % 0815

extends Node3D

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var screen_text: Label3D = $ScreenText
@onready var tasting_screen: Node3D = $TastingScreen

const COOKING_PROMPT_TEMPLATE: String = """
In a pot the following ingredients have been cooked into a stew:
{foods}
Pretend like you just ate that meal. Rate the meal and how much you like/dislike it.
Comment on different attributes of the meal but talk natually, not as a list.
And be brief.
"""

func build_prompt(foods: Array[FoodItemData]) -> String:
	var food_names := foods.map(func(f: FoodItemData) -> String: return f.name)
	var foods_string := ", ".join(food_names) 
	return COOKING_PROMPT_TEMPLATE.format({"foods": foods_string})

func start_tasting(food: Array[FoodItemData]) -> void:
	tasting_screen.set_tasting(true)
	request_tasting(food)

func _sign_request(method: String, originalURL: String, body: String, timestamp: String) -> String:
	var stringToSign := method + originalURL + body + timestamp
	var hmac := HMACContext.new()
	hmac.start(HashingContext.HASH_SHA256, InitApi.cached_value.to_utf8_buffer())
	hmac.update(stringToSign.to_utf8_buffer())
	var digest := hmac.finish()

	# Convert the byte array to hex string
	var signature := ""
	for byte in digest:
		signature += "%02x" % byte

	return signature

func request_tasting(food: Array[FoodItemData]) -> void:
	var timestamp := str(Time.get_unix_time_from_system() as int)
	var body: Dictionary = {
		"contents": [{
			"parts":[{
				"text": build_prompt(food)
			}]
		}]
	}
	var body_json := JSON.stringify(body)
	var url := ENV.get_var("API_URL")
	
	var sig := _sign_request("POST", url, body_json, timestamp)
	var headers := [
		"Content-Type: application/json",
		"x-timestamp: " + timestamp,
		"x-signature: " + sig
		]
	http_request.request(url, headers, HTTPClient.METHOD_POST, body_json)
	http_request.request_completed.connect(_on_tasting_request_completed)

func _on_tasting_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json.get("status") != "success":
		tasting_screen.set_tasting(false)
		screen_text.print_text("Oopsies... Error :(")

	var response_body: Dictionary = json["response"]["body"] 
	var llm_response: String = response_body["candidates"][0]["content"]["parts"][0]["text"]
	tasting_screen.set_tasting(false)
	screen_text.print_text(llm_response)

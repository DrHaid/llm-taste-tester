class_name LLMRequester

signal request_completed(response: String)

var _http_request: HTTPRequest

const COOKING_PROMPT_TEMPLATE: String = """
In a pot the following ingredients have been cooked into a stew:
{foods}
Pretend like you just ate that meal. Rate the meal and how much you like/dislike it.
Comment on different attributes of the meal but talk naturally, not as a list.
And be brief.
"""

func _init(http_request: HTTPRequest) -> void:
	_http_request = http_request

func build_prompt(foods: Array[FoodItemData], _spices: Array[String]) -> String:
	var food_names := foods.map(func(f: FoodItemData) -> String: return f.name)
	var foods_string := ", ".join(food_names)
	return COOKING_PROMPT_TEMPLATE.format({"foods": foods_string})

func _get_url_path(url: String) -> String:
	var url_path := "/"
	var path_start := url.find("/api/")
	if path_start != -1:
		url_path = url.substr(path_start)
	return url_path

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

func request_tasting(foods: Array[FoodItemData], spices: Array[String]) -> void:
	var timestamp := str(Time.get_unix_time_from_system() as int)
	var body: Dictionary = {
		"contents": [{
			"parts":[{
				"text": build_prompt(foods, spices)
			}]
		}]
	}
	var body_json := JSON.stringify(body)
	var full_url := ENV.get_var("API_URL")
	var url_path := _get_url_path(full_url)
	
	var sig := _sign_request("POST", url_path, body_json, timestamp)
	var headers := [
		"Content-Type: application/json",
		"x-timestamp: " + timestamp,
		"x-signature: " + sig
		]
	_http_request.request(full_url, headers, HTTPClient.METHOD_POST, body_json)
	_http_request.request_completed.connect(_on_tasting_request_completed)

func _on_tasting_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: Variant = JSON.parse_string(body.get_string_from_utf8())
	if json.get("status") != "success":
		request_completed.emit(null)

	var response_body: Variant = json["response"]["body"]
	var llm_response: String = response_body["candidates"][0]["content"]["parts"][0]["text"]
	request_completed.emit(llm_response)

class_name LLMRequester

signal request_completed(response: String)

var _http_request: HTTPRequest

const COOKING_PROMPT_TEMPLATE: String = """
In a pot the following ingredients have been cooked into a stew:
{ingredients}
Pretend like you just ate that meal. Rate the meal and how much you like/dislike it.
Comment on different attributes of the meal but talk naturally, not as a list.
And be brief.
"""

const SPICE_THRESHOLDS = {
	3: "a little",
	6: "some",
	9: "a good amount of",
	12: "a lot of",
	15: "heaps of"
}

const SPICE_TEMPLATE = "{amount} {spice}"

func _init(http_request: HTTPRequest) -> void:
	_http_request = http_request

func get_spice_components(spices: Array[String]) -> Array[String]:
	if spices.size() <= 0:
		return []

	var spice_text: Array[String] = []
	var distinct_spices: Array[String]
	distinct_spices.assign(Utils.distinct_entries(spices))
	for spice: String in distinct_spices:
		var amount := spices.count(spice)
		var amount_in_text: String
		for threshold: int in SPICE_THRESHOLDS:
			amount_in_text = SPICE_THRESHOLDS[threshold]
			if amount < threshold:
				break
		spice_text.append(SPICE_TEMPLATE.format({"amount": amount_in_text, "spice": spice}))

	return spice_text

func build_prompt(foods: Array[FoodItemData], spices: Array[String]) -> String:
	var food_names := foods.map(func(f: FoodItemData) -> String: return f.name)
	var spice_amounts := get_spice_components(spices)
	var ingredients := food_names + spice_amounts
	var ingredients_string := ", ".join(ingredients)
	return COOKING_PROMPT_TEMPLATE.format({"ingredients": ingredients_string})

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

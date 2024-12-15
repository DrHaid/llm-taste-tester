extends Node3D

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var screen_text: Label3D = $ScreenText
@onready var tasting_screen: Node3D = $TastingScreen

var response: String = "" 

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

func request_tasting(food: Array[FoodItemData]) -> void:
    var headers := ["Content-Type: application/json"]
    var body: Dictionary = {
        "contents": [{
            "parts":[{
                "text": build_prompt(food)
            }]
        }]
    }
    var body_json := JSON.stringify(body)
    var url := "{0}?key={1}".format([ENV.get_var("API_URL"), ENV.get_var("API_KEY")])
    http_request.request(url, headers, HTTPClient.METHOD_POST, body_json)
    http_request.request_completed.connect(_on_tasting_request_completed)

func _on_tasting_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    var json: Variant = JSON.parse_string(body.get_string_from_utf8())
    response = json["candidates"][0]["content"]["parts"][0]["text"]
    tasting_screen.set_tasting(false)
    screen_text.print_text(response)
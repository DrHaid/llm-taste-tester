extends Resource
class_name Face

enum EYE_MOOD { HAPPY, NORMAL, BLINK, DEAD }
enum MOUTH_MOOD { HAPPY, SMILE, SURPRISED, TONGUE, CHEWING, NONE }
enum MOOD { BLINK, HAPPY, THRILLED, SMILING, CHEWING, SURPRISED, NONE }

const EYES: Dictionary = {
	EYE_MOOD.HAPPY: "<",
	EYE_MOOD.NORMAL: "o",
	EYE_MOOD.BLINK: "(",
	EYE_MOOD.DEAD: "x"
}

const MOUTH: Dictionary = {
	MOUTH_MOOD.HAPPY: "D",
	MOUTH_MOOD.SMILE: ")",
	MOUTH_MOOD.SURPRISED: "0",
	MOUTH_MOOD.TONGUE: "P",
	MOUTH_MOOD.CHEWING: "TIo"
}

@export var mood: MOOD
@export var eyes: EYE_MOOD
@export var mouth: MOUTH_MOOD
@export var min_time: float
@export var max_time: float
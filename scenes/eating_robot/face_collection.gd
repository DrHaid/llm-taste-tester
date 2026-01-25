extends Resource
class_name FaceCollection

@export var collection: Array[Face]
var idle_moods: Array[Face.MOOD] = [Face.MOOD.HAPPY, Face.MOOD.THRILLED, Face.MOOD.SMILING]

func get_random_mood() -> Face.MOOD:
    return idle_moods.pick_random()    

func get_by_mood(mood: Face.MOOD) -> Face:
    var faces := collection.filter(func(f: Face) -> bool: return f.mood == mood)
    return faces[0] if faces else Face.MOOD.HAPPY
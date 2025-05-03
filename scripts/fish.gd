extends Resource

class_name Fish

var id : int
var name: String
var rarity: String
var length: int
var weight: int
var fishScoreThreshold: int
var value:int

func _init(_id:int, _name:String, _rarity:String, _length:int,
 _weight:int, _fishScoreThreshold: int, _value:int):
	id = _id
	name = _name
	rarity = _rarity
	length = _length
	weight = _weight
	fishScoreThreshold = _fishScoreThreshold
	value = _value

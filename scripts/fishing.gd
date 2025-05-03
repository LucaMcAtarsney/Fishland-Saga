extends Node

var isFishing
var power
var fishScore
var chosenFish
@onready var fTimer = $fishTimer
@onready var cTimer = $catchTimer

var all_fish: Array[Fish] = [
	Fish.new(1,"Skibidi Salmon","Ultra Rare",10,20,110,100),
	Fish.new(2,"Tralalero Trout","Rare",8,11,80,60),
	Fish.new(3,"Tung Tung Tuna","Common",12,30,10,20),
	Fish.new(4,"The Michael","Rare",20,30,90,74)
]

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
func _on_player_started_to_fish() -> void:
	isFishing = global.isFishing
	power = global.powerAtcast
	
	# start timer
	fTimer.wait_time = randf_range(1,10)
	fTimer.start()
	
	
	# score based off of charge metre
	fishScore = calcFishScore(power)
	
	# run fish getting algo
	chosenFish = getFish()
	print(chosenFish.name + " - " + chosenFish.rarity + " fishing score= " + str(fishScore))
	
func _on_fish_timer_timeout() -> void:
	# visual indicator that fish has bitten
	cTimer.start()
	global.fish_on_line = chosenFish
	
	
	# send signal
	print("press e to catch!!")	
	
	
	
	
func getFish() -> Fish:
	var shuffled_all_fish: Array[Fish] = all_fish.duplicate()
	shuffled_all_fish.shuffle()
	
	for fish in shuffled_all_fish:
		if fish.fishScoreThreshold <= fishScore:
			return fish
			
	return null
			
func calcFishScore(power) -> int:
	
	var random = rng.randi_range(10,50)
	return random + power
	
func _on_catch_timer_timeout() -> void:
	global.fish_on_line = null
	

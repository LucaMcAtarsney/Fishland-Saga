extends Node2D

@export var time_scale: float = 1.0  # 1 real second = 1 in-game minute
var current_time_minutes: float = 420.0  # Total in-game minutes passed
var timeString

func _process(delta):
	current_time_minutes += delta * time_scale
	get_time_string()

func get_time() -> Dictionary:
	var total_minutes = int(current_time_minutes)
	var hours = (total_minutes / 60) % 24
	var minutes = total_minutes % 60
	return {
		"hours": hours,
		"minutes": minutes
	}

func get_time_string():
	var time = get_time()
	timeString = "%02d:%02d" % [time["hours"], time["minutes"]]

signal sendTime(timeString:String)

func _on_clock_timeout() -> void:
	sendTime.emit(timeString)
	

extends TextureRect

export var periodicity : int = 1
var start_date = null
var seconds_needed : int = 0
var time_elapsed

var seconds_in_a_day = 86400
var seconds_in_an_hour = 3600
var seconds_in_a_minute = 60


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if start_date == null:
		start_date = OS.get_unix_time()
	seconds_needed = periodicity * seconds_in_a_day


func _on_Timer_timeout() -> void:
	time_elapsed = OS.get_unix_time() - start_date
	$Label.text = seconds_to_time(seconds_needed - time_elapsed)
	hint_tooltip = seconds_to_time(seconds_needed - time_elapsed, true)

func seconds_to_time(seconds:int, full:bool = false) -> String:
	if seconds < 0:
		push_error("Received negative seconds:" + str(seconds))
		return "ERROR"

	var days = seconds / seconds_in_a_day
	var seconds_remaining = seconds - (days * seconds_in_a_day)
	var hours = seconds_remaining / seconds_in_an_hour
	seconds_remaining = seconds_remaining - (hours * seconds_in_an_hour)
	var minutes = seconds_remaining / seconds_in_a_minute
	seconds_remaining = seconds_remaining - (minutes * seconds_in_a_minute)
	
	# print_debug(seconds, " : ", days, " ", hours, " ", minutes, " ", seconds_remaining)
	
	var time_left = ""
	var format = {"days":days, "hours":hours, "minutes":minutes, "seconds": seconds_remaining}
	
	if full: 
		time_left = "{days}D {hours}h{minutes}m{seconds}s".format(format)
	elif days:
		time_left = "{days}D".format(format)
	elif hours:
		time_left = "{hours}h{minutes}m".format(format)
	elif minutes:
		time_left = "{minutes}m{seconds}s".format(format)
	else:
		time_left = "{seconds}s".format(format)
	
	
	return time_left

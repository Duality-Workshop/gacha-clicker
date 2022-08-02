extends Node


var flag_states = {} # id : state (bool)
var flag_callbacks = {} # id : callback (string)
var upgrade_flags = {} # upgrade_id : flag_id

func _ready() -> void:
	flag_states = {
		1: false
	}
	flag_callbacks = {
		1: "yeehaw"
	}
	upgrade_flags = {
		1: 1
	}

func toggle_flag(flag_id:int) -> void:
	if not flag_states[flag_id]:
		push_error("Tried to toggle inexisting flag: " + str(flag_id))
	
	flag_states[flag_id] = not flag_states[flag_id]
	
	if flag_callbacks[flag_id]:
		call(flag_callbacks[flag_id])


func call_upgrade_flag(upgrade_id:int) -> void:
	if upgrade_flags[upgrade_id]:
		toggle_flag(upgrade_flags[upgrade_id])


#######################################################
##################   CALLBACKS   ######################
#######################################################

func yeehaw() -> void:
	print("yeehaw")

extends Panel


var unit_scene = preload("res://Scenes/PartyMember.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var unit_container = $VBoxContainer/ScrollContainer/VBoxContainer
	
	for unit in Manager.get_owned_units(): # Get all owned units
		if not Manager.get_party().has(unit): # Don't parse enlisted units
			var member = unit_scene.instance()
			member.update_info(unit)
			unit_container.add_child(member)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

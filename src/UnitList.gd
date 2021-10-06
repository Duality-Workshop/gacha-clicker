extends Panel


var unit_scene = preload("res://Scenes/PartyMember.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Manager.connect("unit_updated", self, "_on_unit_updated")
	
	for unit in Manager.get_owned_units(): # Get all owned units
		if not Manager.get_party().has(unit): # Don't parse enlisted units
			add_unit(unit)

func add_unit(unit):
	var unit_container = $VBoxContainer/ScrollContainer/VBoxContainer
	var member = unit_scene.instance()
	member.update_info(unit)
	member.name = unit.name
	unit_container.add_child(member)

func _on_unit_updated(unit, update):
	match update:
		"enlist":
			get_node("VBoxContainer/ScrollContainer/VBoxContainer/" + unit.name).queue_free()
		"remove":
			add_unit(unit)
		"new":
			add_unit(unit)
		"rank_up":
			var unit_container
			if not Manager.get_party().has(unit):
				unit_container = get_node("VBoxContainer/ScrollContainer/VBoxContainer/" + unit.name)
				unit_container.rank_up()

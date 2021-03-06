extends Panel


var unit_scene = preload("res://Scenes/PartyMember.tscn")


# Called from Manager once the board is loaded.
func start():
	init_list()


func init_list():
	var party_list = $VBoxContainer.get_node("VBoxContainer")
	for n in party_list.get_children():
		party_list.remove_child(n)
		n.queue_free()

	for unit in Manager.party:
		var member = unit_scene.instance()
		member.update_info(unit)
		member.name = unit.name
		party_list.add_child(member)


func _on_unit_updated(unit, update):
	match update:
		"enlist":
			init_list()
		"remove":
			get_node("VBoxContainer/VBoxContainer/" + unit.name).queue_free()
		"rank_up":
			var unit_container
			if Manager.get_party().has(unit):
				unit_container = get_node("VBoxContainer/VBoxContainer/" + unit.name)
				unit_container.rank_up()

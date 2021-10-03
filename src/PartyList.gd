extends Panel


var unit_scene = preload("res://Scenes/PartyMember.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var party_list = $VBoxContainer.get_node("VBoxContainer")
	for unit in Manager.party:
		var member = unit_scene.instance()
		member.update_info(unit)
		party_list.add_child(member)


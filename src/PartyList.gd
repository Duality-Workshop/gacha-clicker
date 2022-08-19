extends Panel

onready var drop_target = get_node("%UnitList")
onready var unit_scene: PackedScene = preload("res://Scenes/PartyMember.tscn")
onready var added_scene: PackedScene = preload("res://Scenes/PartyAddedPanel.tscn")
onready var draggable_container = $VBoxContainer/VBoxContainer
var is_mouse_in := false


func _process(_delta: float) -> void:
	var item_count = draggable_container.get_child_count()
	if is_mouse_in and Manager.is_dragging and item_count > 0:
		# Find which unit is being hovered
		var item_index := -1
		for item in draggable_container.get_children():
			if item.is_hovered:
				item_index = Manager.get_unit_index(item.unit.id)
				break
		
		if item_index == -1:
			draggable_container.get_child(item_count - 1).get_node("VBoxContainer").get_node("SpacerBottom").show()
		else:
			draggable_container.get_child(item_count - 1).get_node("VBoxContainer").get_node("SpacerBottom").hide()

# Called from Manager once the board is loaded.
func start():
	init_list()

func init_list():
	var party_list = $VBoxContainer.get_node("VBoxContainer")
	
	# Empty the party
	for n in party_list.get_children():
		party_list.remove_child(n)
		n.queue_free()
	
	# Fill up the party
	for unit in Manager.party:
		var member = unit_scene.instance()
		member.update_info(unit)
		member.name = unit.name
		party_list.add_child(member)


func _on_unit_updated(unit, update):
	match update:
		"enlist":
			init_list() # TODO: surely there has to be a better way
			
			# Display added to party dialog
			var added_dialog = added_scene.instance()
			added_dialog.line = tr(unit.name.to_upper() + "_ADDED_TO_PARTY")
			
			var unit_container = get_node("VBoxContainer/VBoxContainer/" + unit.name)
			unit_container.get_node("DialogControl").add_child(added_dialog)
		"remove":
			get_node("VBoxContainer/VBoxContainer/" + unit.name).queue_free()
		"reorder":
			if unit.party:
				var unit_container = get_node("VBoxContainer/VBoxContainer/" + unit.name)
				draggable_container.move_child(unit_container, Manager.get_unit_index(unit.id))
		"rank_up":
			var unit_container
			if Manager.get_party().has(unit):
				unit_container = get_node("VBoxContainer/VBoxContainer/" + unit.name)
				unit_container.rank_up()

func can_drop_data(_position: Vector2, data: Unit) -> bool:
	var can_drop: bool = data is Unit and (Manager.party.size() < 6 or data.party)
	return can_drop

func drop_data(_position: Vector2, data: Unit) -> void:
	Manager.is_dragging = false
	
	var party_size = Manager.party.size()
	
	if party_size == 0:
		Manager.add_to_party(data.id)
	else:
		if party_size:
			# Remove the bottom spacer
			draggable_container.get_child(party_size - 1).get_node("VBoxContainer").get_node("SpacerBottom").hide()
		
		# Find where this was dropped
		var item_index := -1
		for item in draggable_container.get_children():
			if item.is_hovered:
				item_index = Manager.get_unit_index(item.unit.id)
				break
		
		if data.party:
			Manager.reorder_unit(data.id, item_index)
		else:
			if item_index == -1:
				Manager.add_to_party(data.id)
			else:
				Manager.add_to_party(data.id, item_index)

func _on_PartyList_mouse_entered() -> void:
	is_mouse_in = true

func _on_PartyList_mouse_exited() -> void:
	is_mouse_in = false
	
	var item_count = draggable_container.get_child_count()
	if item_count:
		draggable_container.get_child(item_count - 1).get_node("VBoxContainer").get_node("SpacerBottom").hide()

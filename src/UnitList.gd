extends Panel

onready var drop_target = get_node("%PartyList")
onready var unit_scene: PackedScene = preload("res://Scenes/PartyMember.tscn")
onready var draggable_container = $VBoxContainer/ScrollContainer/VBoxContainer
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
	for unit in Manager.get_owned_units(): # Get all owned units
		if not Manager.get_party().has(unit): # Don't parse enlisted units
			add_unit(unit)

func add_unit(unit):
	var unit_container = $VBoxContainer/ScrollContainer/VBoxContainer
	var member = unit_scene.instance()
	member.update_info(unit)
	member.name = unit.name
	unit_container.add_child(member)
	var unit_index = Manager.get_unit_index(unit.id)
	if unit_index != -1:
		unit_container.move_child(unit_container.get_child(unit_container.get_child_count() - 1), unit_index)


func _on_unit_updated(unit, update):
	match update:
		"enlist":
			get_node("VBoxContainer/ScrollContainer/VBoxContainer/" + unit.name).queue_free()
		"remove":
			add_unit(unit)
		"reorder":
			if not unit.party:
				var unit_container = get_node("VBoxContainer/ScrollContainer/VBoxContainer/" + unit.name)
				draggable_container.move_child(unit_container, Manager.get_unit_index(unit.id))
		"new":
			add_unit(unit)
		"rank_up":
			var unit_container
			if not Manager.get_party().has(unit):
				unit_container = get_node("VBoxContainer/ScrollContainer/VBoxContainer/" + unit.name)
				unit_container.rank_up()


func can_drop_data(_position: Vector2, data) -> bool:
	var can_drop: bool = data is Unit
	return can_drop

func drop_data(_position: Vector2, data: Unit) -> void:
	Manager.is_dragging = false
		
	var reserve_size = Manager.reserve.size()
	
	if reserve_size == 0:
		Manager.remove_from_party(data.id)
	else:
		if reserve_size:
			# Remove the bottom spacer
			draggable_container.get_child(reserve_size - 1).get_node("VBoxContainer").get_node("SpacerBottom").hide()
		
		# Find where this was dropped
		var item_index := -1
		for item in draggable_container.get_children():
			if item.is_hovered:
				item_index = Manager.get_unit_index(item.unit.id)
				break
		
		if not data.party:
			Manager.reorder_unit(data.id, item_index)
		else:
			if item_index == -1:
				Manager.remove_from_party(data.id)
			else:
				Manager.remove_from_party(data.id, item_index)

func _on_UnitList_mouse_entered() -> void:
	is_mouse_in = true

func _on_UnitList_mouse_exited() -> void:
	is_mouse_in = false
	
	var item_count = draggable_container.get_child_count()
	if item_count:
		draggable_container.get_child(item_count - 1).get_node("VBoxContainer").get_node("SpacerBottom").hide()

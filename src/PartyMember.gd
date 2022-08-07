extends Panel

var unit

export var id: int
export var label: String
var source: Control

onready var preview_scene: PackedScene = preload("res://Scenes/PartyMemberPreview.tscn")
var resource_particle_emitter = preload("res://Scenes/ResourceParticle.tscn")
var is_hovered


func update_info(_unit:Unit):
	self.unit = _unit
	if unit.party:
		$CycleTimer.wait_time = unit.get_cycle()
		$EnlistButton.visible = false
	else:
		$CycleTimer.stop()
		$RemoveButton.visible = false
		if Manager.party.size() == 6:
			$EnlistButton.visible = false
	
	
	### Display infos
	# Rank
	var rank_star = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/RankStar
	
	# Which big star?
	if unit.rank == 30:
		rank_star.texture = load("res://Resources/Icons/Star3.png")
	elif unit.rank >= 20:
		rank_star.texture = load("res://Resources/Icons/Star2.png")
	elif unit.rank >= 10:
		rank_star.texture = load("res://Resources/Icons/Star.png")
	
	# How many bits?
	var rank_overflow = unit.rank % 10
	
	# Display bits
	var grid = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/GridContainer
	for _i in range(rank_overflow):
		var bit = TextureRect.new()
		bit.texture = load("res://Resources/Icons/bit.png")
		grid.add_child(bit)
	
	
	# Name
	$VBoxContainer/HBoxContainer/VBoxContainer/Name.text = unit.name
	
	# Portrait
	var tex : Texture
	var tex_path = "res://Resources/Portraits/" + unit.name.to_lower() + " - portrait.png"
	if ResourceLoader.exists(tex_path):
		tex = load(tex_path)
	else:
		tex = load("res://Resources/Portraits/unknown - portrait.png")
	$VBoxContainer/HBoxContainer/Portrait.texture = tex
	
	# Resource(s)
	var resource1 = $VBoxContainer/HBoxContainer/HBoxContainer/Resource1
	var resource2 = $VBoxContainer/HBoxContainer/HBoxContainer/Resource2
	
	if len(unit.resources) == 0:
		resource1.visible = false
		resource2.visible = false
		
	elif len(unit.resources) == 1:
		resource1.color = Helper.get_resource_color(unit.resources[0])
		resource2.visible = false
		
	elif len(unit.resources) == 2:
		resource1.color = Helper.get_resource_color(unit.resources[0])
		resource2.color = Helper.get_resource_color(unit.resources[1])


func rank_up():
	### Display rank
	var rank_star = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/RankStar
	
	# Which big star?
	if unit.rank == 30:
		rank_star.texture = load("res://Resources/Icons/Star3.png")
	elif unit.rank >= 20:
		rank_star.texture = load("res://Resources/Icons/Star2.png")
	elif unit.rank >= 10:
		rank_star.texture = load("res://Resources/Icons/Star.png")
	
	# How many bits?
	var rank_overflow = unit.rank % 10
	
	# Display bits
	var grid = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/GridContainer
	if rank_overflow > 0:
		var bit = TextureRect.new()
		bit.texture = load("res://Resources/Icons/bit.png")
		grid.add_child(bit)
	else:
		for n in grid.get_children():
			grid.remove_child(n)
			n.queue_free()


func _on_CycleTimer_timeout():
	$AnimationPlayer.play("Generate")
	for resource in unit.resources:
		Manager.unit_add_resource(unit, resource)
		
		var emitter = resource_particle_emitter.instance()
		var portrait = $VBoxContainer/HBoxContainer/Portrait
		emitter.position = Vector2(portrait.rect_position.x + portrait.rect_size.x / 2, portrait.rect_position.y + portrait.rect_size.y / 2)
		emitter.emitting = true
		emitter.process_material.emission_box_extents = Vector3(portrait.rect_size.x / 2, portrait.rect_size.y / 2, 0)
		emitter.process_material.color = Helper.get_resource_color(resource)
		add_child(emitter)
	
	$CycleTimer.wait_time = unit.get_cycle()


func _on_EnlistButton_pressed():
	Manager.add_to_party(unit.id)


func _on_RemoveButton_pressed():
	Manager.remove_from_party(unit.id)


################################
#        DRAG FEATURE          #
################################
func get_drag_data(position: Vector2):
	set_drag_preview(_get_preview_control(position))
	Manager.is_dragging = true
	return unit

func _get_preview_control(cur_pos: Vector2) -> Control:
	"""
	The preview control must not be in the scene tree. You should not free the control, and
	you should not keep a reference to the control beyond the duration of the drag.
	It will be deleted automatically after the drag has ended.
	"""
	var preview = preview_scene.instance()
	preview.unit = unit
	preview.offset = cur_pos
	# preview.rect_size = $PartyMember.rect_size
	# Decide whether to lean left or right
	var x_delta = (cur_pos.x - rect_size.x / 2) / (rect_size.x / 2)
	preview.set_rotation(-x_delta * .1) # in radians
	#preview.set_position(Vector2(-50.0, -50.0))
	return preview


func _on_PartyMember_mouse_entered() -> void:
	is_hovered = true
	if Manager.is_dragging:
		$VBoxContainer/SpacerTop.color.a = 1.0


func _on_PartyMember_mouse_exited() -> void:
	is_hovered = false
	$VBoxContainer/SpacerTop.color.a = 0.0

extends Panel

var resource_particle_emitter = preload("res://Scenes/ResourceParticle.tscn")


var unit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_info(unit:Unit):
	self.unit = unit
	if unit.party:
		$CycleTimer.wait_time = unit.get_cycle()
		$EnlistButton.visible = false
	else:
		$CycleTimer.stop()
		$RemoveButton.visible = false
		if Manager.party.size() == 6:
			$EnlistButton.visible = false
	
	
	### Display rank
	var rank_star = $HBoxContainer/VBoxContainer/HBoxContainer/RankStar
	
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
	var grid = $HBoxContainer/VBoxContainer/HBoxContainer/GridContainer
	for i in range(rank_overflow):
		var bit = TextureRect.new()
		bit.texture = load("res://Resources/Icons/bit.png")
		grid.add_child(bit)
	
	
	### Display resources
	get_node("HBoxContainer/VBoxContainer/Name").text = unit.name
	var resource1 = get_node("HBoxContainer/HBoxContainer/Resource1")
	var resource2 = get_node("HBoxContainer/HBoxContainer/Resource2")
	
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
	var rank_star = $HBoxContainer/VBoxContainer/HBoxContainer/RankStar
	
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
	var grid = $HBoxContainer/VBoxContainer/HBoxContainer/GridContainer
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
		var portrait = $HBoxContainer/Portrait
		emitter.position = Vector2(portrait.rect_position.x + portrait.rect_size.x / 2, portrait.rect_position.y + portrait.rect_size.y / 2)
		emitter.emitting = true
		emitter.process_material.emission_box_extents = Vector3(portrait.rect_size.x / 2, portrait.rect_size.y / 2, 0)
		emitter.process_material.color = Helper.get_resource_color(resource)
		add_child(emitter)
	
	$CycleTimer.wait_time = unit.get_cycle()


func _on_EnlistButton_pressed():
	Manager.add_to_party(unit.name)


func _on_RemoveButton_pressed():
	Manager.remove_from_party(unit.name)

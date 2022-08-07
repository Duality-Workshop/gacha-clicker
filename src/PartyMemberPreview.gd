extends Container

var offset: Vector2
var unit: Unit


func _ready() -> void:
	# Preview offset
	$PartyMember.rect_position -= offset
	
	### Display infos
	# Rank
	var rank_star = $PartyMember/HBoxContainer/VBoxContainer/HBoxContainer/RankStar
	
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
	var grid = $PartyMember/HBoxContainer/VBoxContainer/HBoxContainer/GridContainer
	for _i in range(rank_overflow):
		var bit = TextureRect.new()
		bit.texture = load("res://Resources/Icons/bit.png")
		grid.add_child(bit)
	
	
	# Name
	$PartyMember/HBoxContainer/VBoxContainer/Name.text = unit.name
	
	# Portrait
	var tex : Texture
	var tex_path = "res://Resources/Portraits/" + unit.name.to_lower() + " - portrait.png"
	if ResourceLoader.exists(tex_path):
		tex = load(tex_path)
	else:
		tex = load("res://Resources/Portraits/unknown - portrait.png")
	$PartyMember/HBoxContainer/Portrait.texture = tex
	
	# Resource(s)
	var resource1 = $PartyMember/HBoxContainer/HBoxContainer/Resource1
	var resource2 = $PartyMember/HBoxContainer/HBoxContainer/Resource2
	
	if len(unit.resources) == 0:
		resource1.visible = false
		resource2.visible = false
		
	elif len(unit.resources) == 1:
		resource1.color = Helper.get_resource_color(unit.resources[0])
		resource2.visible = false
		
	elif len(unit.resources) == 2:
		resource1.color = Helper.get_resource_color(unit.resources[0])
		resource2.color = Helper.get_resource_color(unit.resources[1])

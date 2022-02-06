extends WindowDialog


var groups = {}
var odds = 0.00


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	groups = {
		"Traits": $VBoxContainer/HBoxContainer/ButtonRows/Traits.group,
		"Flaws": $VBoxContainer/HBoxContainer/ButtonRows/Flaws.group,
		"Style": $VBoxContainer/HBoxContainer/ButtonRows/Style.group,
		"Speed": $VBoxContainer/HBoxContainer/ButtonRows/Speed.group
	}


func retrieve_tags() -> Array:
	var tags = []
	
	for group in groups.values():
		var button = group.get_pressed_button()
		if button != null:
			tags.append(button.text)
	
	return tags

func get_matching_units(tags) -> Array:
	var matching_units = []
	
	for unit in Manager.units:
		var valid = true
		for tag in tags:
			if not tag.to_lower().capitalize() in Manager.units[unit].tags:
				valid = false
				break
		
		if valid:
			matching_units.append(Manager.units[unit])
	
	return matching_units



func _on_Button_pressed() -> void:
	var tags = retrieve_tags()
	var units = get_matching_units(tags)
	
	while not units:
		if tags:
			tags.pop_back()
			units = get_matching_units(tags)
		else:
			push_error("Couldn't return any matching unit even with no tag")
	
	
	var valid_units = []
	var pullable_units = Manager.get_pullable_units()
	
	for unit in units:
		if unit in pullable_units:
			valid_units.append(unit)
	
	var rng = RandomNumberGenerator.new()
	if Manager.RANDOM: rng.randomize()
	var roll = rng.randf()
	
	if roll <= odds:
		var i = rng.randi_range(0, len(valid_units) - 1)
		Manager.pull_unit(valid_units[i])
	else:
		var i = rng.randi_range(0, len(pullable_units) - 1)
		Manager.pull_unit(pullable_units[i])
	

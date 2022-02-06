extends WindowDialog


var groups = {}


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


func _on_Button_pressed() -> void:
	var matching_unit = []
	
	var tags = retrieve_tags()
	
	for unit in Manager.units:
		var valid = true
		for tag in tags:
			if not tag.to_lower().capitalize() in Manager.units[unit].tags:
				valid = false
				break
		
		if valid:
			matching_unit.append(Manager.units[unit].name)
	
	print_debug(matching_unit)

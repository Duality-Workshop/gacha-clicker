extends Panel


var resource_nodes


# Called when the node enters the scene tree for the first time.
func _ready():
	resource_nodes = {
		"Weapons": $VBoxContainer/HBoxContainer/Weapons, 
		"Potions": $VBoxContainer/HBoxContainer/Potions, 
		"Scrolls": $VBoxContainer/HBoxContainer/Scrolls, 
		"Food": $VBoxContainer/HBoxContainer/Food, 
		"Blueprints": $VBoxContainer/HBoxContainer/Blueprints
	}


func update_resource(resource, amount):
	#print_debug("updating resource " + resource + " by " + str(amount))
	#print_debug(resource_nodes[resource])
	resource_nodes[resource].increase_amount(amount)

extends Panel


var resource_nodes


# Called when the node enters the scene tree for the first time.
func _ready():
	resource_nodes = {
		Helper.RESOURCE_TYPE.WEAPONS: $VBoxContainer/HBoxContainer/Weapons, 
		Helper.RESOURCE_TYPE.POTIONS: $VBoxContainer/HBoxContainer/Potions, 
		Helper.RESOURCE_TYPE.SCROLLS: $VBoxContainer/HBoxContainer/Scrolls, 
		Helper.RESOURCE_TYPE.FOOD: $VBoxContainer/HBoxContainer/Food, 
		Helper.RESOURCE_TYPE.BLUEPRINTS: $VBoxContainer/HBoxContainer/Blueprints
	}


func update_resource(resource, amount):
	#print_debug("updating resource " + resource + " by " + str(amount))
	#print_debug(resource_nodes[resource])
	resource_nodes[resource].increase_amount(amount)

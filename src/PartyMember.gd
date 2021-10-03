extends Panel


var unit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_info(unit:Unit):
	self.unit = unit
	$CycleTimer.wait_time = unit.cycle
	get_node("HBoxContainer/VBoxContainer/Name").text = unit.name
	var resource1 = get_node("HBoxContainer/HBoxContainer/Resource1")
	var resource2 = get_node("HBoxContainer/HBoxContainer/Resource2")
	
	if len(unit.resources) == 0:
		resource1.visible = false
		resource2.visible = false
		
	elif len(unit.resources) == 1:
		resource1.color = Helper.resource_colors[unit.resources[0]]
		resource2.visible = false
		
	elif len(unit.resources) == 2:
		resource1.color = Helper.resource_colors[unit.resources[0]]
		resource2.color = Helper.resource_colors[unit.resources[1]]


func _on_CycleTimer_timeout():
	for resource in unit.resources:
		Manager.update_resource(resource, unit.power * unit.rank)

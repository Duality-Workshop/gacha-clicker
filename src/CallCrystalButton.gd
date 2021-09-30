extends Button

var resources = ["Weapons", "Potions", "Scrolls", "Food", "Blueprints"]
var clicks = 0
signal increase_resource(resource, value)


func _on_CallCrystalButton_pressed():
	clicks += 1
	$AmountLabel.text = str(clicks)
	var resource = resources[rand_range(0, resources.size())]
	
	emit_signal("increase_resource", resource, 1)

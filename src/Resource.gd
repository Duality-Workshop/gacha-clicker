extends HBoxContainer


export(String, "Select a type", "Weapons", "Potions", "Scrolls", "Food", "Blueprints") var type
var amount = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$Amount.text = str(amount)
	
	var icon = $Icon
	icon.color = Helper.resource_colors[type]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func increase_amount(value):
	amount += value
	$Amount.text = str(floor(amount))


func _on_CallCrystalButton_increase_resource(resource, value):
	if resource == type:
		increase_amount(value)

extends Polygon2D


export(String, "Select a type", "Weapons", "Potions", "Scrolls", "Food", "Blueprints") var type
var amount = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	match type:
		"Weapons":
			color = Color(0.67451, 0.258824, 0.258824)
		"Potions":
			color = Color(0.258824, 0.67451, 0.266667)
		"Scrolls":
			color = Color(0.643137, 0.258824, 0.67451)
		"Food":
			color = Color(0.8, 0.635294, 0.141176)
		"Blueprints":
			color = Color(0.266667, 0.262745, 0.788235)
		_:
			color = Color(1, 0, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func increase_amount(value):
	amount += value
	$Amount.text = str(amount)


func _on_CallCrystalButton_increase_resource(resource, value):
	if resource == type:
		increase_amount(value)

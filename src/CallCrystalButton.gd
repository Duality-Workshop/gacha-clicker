extends Button

const resources = ["Weapons", "Potions", "Scrolls", "Food", "Blueprints"]
var roll_odds = {
	"Weapons": 100, 
	"Potions": 100, 
	"Scrolls": 100, 
	"Food": 100, 
	"Blueprints": 10,
	"Unit": 1
	}
var roll_sum
var roll_table = {}


var clicks = 0
signal increase_resource(resource, value)

func _ready():
	var s = 0
	for odd in roll_odds:
		s += roll_odds[odd]
		roll_table[str(s)] = odd
	roll_sum = s
	
	print_debug(roll_table)


func _on_CallCrystalButton_pressed():
	clicks += 1
	$AmountLabel.text = str(clicks)
	var roll = rand_range(0, roll_sum)
	var result
	
	for odd in roll_table:
		if roll < int(odd):
			result = roll_table[odd]
			break
	
	if result in resources:
		emit_signal("increase_resource", result, 1)
	else:
		print_debug("Pulled a unit!")

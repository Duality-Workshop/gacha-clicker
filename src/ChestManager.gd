extends Control


var chest_node = preload("res://Scenes/Chest.tscn")
var rng = RandomNumberGenerator.new()

const resources = ["Weapons", "Potions", "Scrolls", "Food", "Blueprints"]
var roll_odds = {
	"Weapons": 100, 
	"Potions": 100, 
	"Scrolls": 100, 
	"Food": 100, 
	"Blueprints": 10,
	"Callerite": 10
	}
var roll_sum
var roll_table = {}

var roll_amount = 10

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	if Manager.RANDOM: rng.randomize()
	
	var s = 0
	for odd in roll_odds:
		s += roll_odds[odd]
		roll_table[str(s)] = odd
	roll_sum = s

func _on_ChestTimer_timeout() -> void:
	var chest_instance = chest_node.instance()
	var rand_x = rng.randi_range(0, rect_size.x)
	var rand_y = rng.randi_range(0, rect_size.y)
	chest_instance.set_position(Vector2(rand_x, rand_y))
	fill_chest(chest_instance)
	add_child(chest_instance)

func fill_chest(chest:Control) -> void:
	for _i in range(roll_amount):
		chest.rewards.append(roll_reward())

func roll_reward() -> Dictionary:
	var roll = rng.randi_range(0, roll_sum)
	var result
	
	for odd in roll_table:
		if roll < int(odd):
			result = roll_table[odd]
			break
	
	return result

extends Control


var chest_node = preload("res://Scenes/Chest.tscn")
var rng = RandomNumberGenerator.new()

const resources = ["Tools", "Potions", "Scrolls", "Food", "Blueprints"]
var roll_odds = {}
var roll_sum
var roll_table = {}

var roll_amount = 10

export(int) var spawn_timer = 30
export(int) var despawn_timer = 10

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	if Manager.RANDOM: rng.randomize()
	
	roll_odds = {
		Helper.RESOURCE_TYPE.TOOLS: 100,
		Helper.RESOURCE_TYPE.SCROLLS: 100,
		Helper.RESOURCE_TYPE.POTIONS: 100,
		Helper.RESOURCE_TYPE.FOOD: 100,
		Helper.RESOURCE_TYPE.BLUEPRINTS: 10,
		"Callerite": 10
	}
	
	$ChestTimer.wait_time = spawn_timer
	
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
	chest_instance.get_node("Timer").wait_time = despawn_timer
	fill_chest(chest_instance)
	add_child(chest_instance)

func fill_chest(chest:Control) -> void:
	for _i in range(roll_amount):
		chest.rewards.append(roll_reward())

func roll_reward() -> Dictionary:
	var roll = rng.randi_range(0, roll_sum)
	var result
	
	for odd in roll_table:
		if roll <= int(odd):
			result = roll_table[odd]
			break
	
	return result

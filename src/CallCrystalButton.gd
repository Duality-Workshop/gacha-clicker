extends Button

var resource_particle_emitter = preload("res://Scenes/ResourceParticle.tscn")
var spark_particle_emitter = preload("res://Scenes/SparkParticle.tscn")

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
	var rng = RandomNumberGenerator.new()
	if Manager.RANDOM: rng.randomize()
	var roll = rng.randi_range(0, roll_sum)
	var result
	
	for odd in roll_table:
		if roll < int(odd):
			result = roll_table[odd]
			break
	
	if result in resources:
		emit_signal("increase_resource", result, 1)
		
		var r_emitter = resource_particle_emitter.instance()
		r_emitter.emitting = true
		r_emitter.process_material.color = Helper.get_resource_color(result)
		add_child(r_emitter)
		
		var s_emitter = spark_particle_emitter.instance()
		s_emitter.position = get_local_mouse_position()
		s_emitter.emitting = true
		add_child(s_emitter)
	else:
		Manager.pull_random()

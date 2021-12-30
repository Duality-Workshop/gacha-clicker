extends Button

var resource_particle_emitter = preload("res://Scenes/ResourceParticle.tscn")
var spark_particle_emitter = preload("res://Scenes/SparkParticle.tscn")
var crystal_particle_emitter = preload("res://Scenes/CrystalParticle.tscn")

var roll_odds = {}
var roll_sum
var roll_table = {}


var clicks = 0
signal increase_resource(resource, value)

func _ready():
	roll_odds = {
		Helper.RESOURCE_TYPE.WEAPONS: 100,
		Helper.RESOURCE_TYPE.SCROLLS: 100,
		Helper.RESOURCE_TYPE.POTIONS: 100,
		Helper.RESOURCE_TYPE.FOOD: 100,
		Helper.RESOURCE_TYPE.BLUEPRINTS: 10,
		"Unit": 1
	}
	
	var s = 0
	for odd in roll_odds:
		s += roll_odds[odd]
		roll_table[str(s)] = odd
	roll_sum = s


func _on_CallCrystalButton_pressed():
	if $Timer.time_left == 0:
		$Timer.start()
		disabled = true
		clicks += 1
		$AmountLabel.text = str(clicks)
		var rng = RandomNumberGenerator.new()
		if Manager.RANDOM: rng.randomize()
		var roll = rng.randi_range(0, roll_sum)
		var result
		
		for odd in roll_table:
			if roll <= int(odd):
				result = roll_table[odd]
				break
		
		if result in Helper.RESOURCE_TYPE.values():
			emit_signal("increase_resource", result, Manager.get_click_power(result))
			
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
			
			var emitter = crystal_particle_emitter.instance()
			emitter.position = get_local_mouse_position()
			emitter.emitting = true
			add_child(emitter)


func _on_Timer_timeout() -> void:
	disabled = false

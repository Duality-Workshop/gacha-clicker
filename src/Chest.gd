extends Control

var resource_particle_emitter = preload("res://Scenes/ResourceParticle.tscn")
var crystal_particle_emitter = preload("res://Scenes/CrystalParticle.tscn")

var rng = RandomNumberGenerator.new()
var rewards := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite/AnimationPlayer.play("Appear")
	$Sprite.mouse_filter = MOUSE_FILTER_IGNORE
	$Sprite/Label.mouse_filter = MOUSE_FILTER_IGNORE
	
	if Manager.RANDOM: rng.randomize()
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Chest_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			$Sprite/AnimationPlayer.play("Open")
			
			for reward in rewards:
				if reward["reward"] == "Callerite":					
					var emitter = crystal_particle_emitter.instance()
					emitter.emitting = true
					add_child(emitter)
				else:
					Manager.add_resource(reward["reward"], reward["amount"])
					var emitter = resource_particle_emitter.instance()
					emitter.position = get_local_mouse_position()
					emitter.emitting = true
					emitter.process_material.emission_box_extents = Vector3(0,0,0)
					emitter.process_material.color = Helper.get_resource_color(reward["reward"])
					add_child(emitter)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Open":
		queue_free()

extends Control

var slot_to_load : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_save_slot_selected(slot: int) -> void:
	slot_to_load = slot
	$ColorRect/AnimationPlayer.play("GoDark")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "GoDark":
		load_game()


func load_game() -> void:
	#TODO: load save file here
	
	var scene = load("res://Scenes/Board.tscn")
	var err = get_tree().change_scene_to(scene)
	
	if err:
		push_error("Couldn't load save file!")

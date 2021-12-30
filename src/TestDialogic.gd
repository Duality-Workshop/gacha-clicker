extends Button


var new_dialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_dialog = Dialogic.start('GLORIA_INTRO1_PART2')
	new_dialog.connect("timeline_end", self, "after_dialog")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Button_pressed() -> void:
	get_parent().get_node("AnimationPlayer").play("Fade")
	add_child(new_dialog)


func after_dialog(timeline_name) -> void:
		get_parent().get_node("AnimationPlayer").play_backwards("Fade")

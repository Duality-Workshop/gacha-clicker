extends Button


var new_dialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_dialog = Dialogic.start('GLORIA_INTRO1_PART1')


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Button_pressed() -> void:
	add_child(new_dialog)

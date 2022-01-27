extends Button

signal slot_selected(slot)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_tree().current_scene
	var err = connect("slot_selected", root, "_on_save_slot_selected")
	if err:
		push_error("Couldn't connect signal slot_selected to the board")


func _on_Button_pressed() -> void:
	emit_signal("slot_selected", int(text))

extends Button

signal slot_selected(slot)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_tree().current_scene
	connect("slot_selected", root, "_on_save_slot_selected")


func _on_Button_pressed() -> void:
	emit_signal("slot_selected", int(text))

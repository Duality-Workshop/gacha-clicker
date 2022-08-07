extends HBoxContainer

# Current dock status
var open = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Opening/closing animation
func _on_UnitListButton_pressed() -> void:
	if open:
		$AnimationPlayer.play("Close")
	else:
		$AnimationPlayer.play("Open")
	
	open = !open

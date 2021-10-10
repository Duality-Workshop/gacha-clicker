extends HBoxContainer


var open = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_UnitListButton_pressed() -> void:
	if open:
		$AnimationPlayer.play("Close")
	else:
		$AnimationPlayer.play("Open")
	
	open = !open

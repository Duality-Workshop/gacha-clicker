extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Manager.pulls:
		visible = true
		$Label.text = str(len(Manager.pulls)) + " call" + ("s" if len(Manager.pulls) > 1 else "") + " waiting!"
	else:
		visible = false


func _on_PullContainer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		for unit in [] + Manager.pulls:  # We want a copy of the list, because it will change as we go through
			Manager.pull_unit(unit)

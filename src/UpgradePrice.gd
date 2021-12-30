extends HBoxContainer


var resource : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_affordable():
		$Amount.set("custom_colors/font_color", Color.white)
	else:
		$Amount.set("custom_colors/font_color", Color.red)

func is_affordable() -> bool:
	return int($Amount.text) <= Manager.resources[resource]

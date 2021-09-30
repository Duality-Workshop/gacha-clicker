extends Button


var hover = false
var description = null


# Called when the node enters the scene tree for the first time.
func _ready():
	description = $Description
	description.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if hover:
		description.rect_position = get_local_mouse_position()


func _on_UpgradeButton_mouse_entered():
	hover = true
	description.visible = true


func _on_UpgradeButton_mouse_exited():
	hover = false
	description.visible = false

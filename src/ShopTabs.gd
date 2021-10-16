extends TabContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(get_tab_count()):
		set_tab_title(i, get_tab_control(i).tab_name)

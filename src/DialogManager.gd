extends ColorRect


var new_dialog
var faded_in: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func start_dialogue(timeline: String, callback: Node = null, callback_target: String = "") -> void:
	new_dialog = Dialogic.start(timeline)
	
	if callback:
		new_dialog.connect("timeline_end", callback, callback_target)
	else:
		new_dialog.connect("timeline_end", self, "after_dialogue")
		
	if not faded_in:
		$AnimationPlayer.play("Fade")
		faded_in = true
	add_child(new_dialog)


func after_dialogue(_timeline_name) -> void:
	$AnimationPlayer.play_backwards("Fade")
	faded_in = false

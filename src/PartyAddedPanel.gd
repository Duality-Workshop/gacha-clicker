extends PanelContainer

var line: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = line
	# Text should be displayed at about 0.5 second per word, or at least 3 seconds total, whichever is higher
	$Timer.wait_time = max(3, len(line.split(" ")) * .5) 
	$AnimationPlayer.play("Appear")

func _on_Timer_timeout() -> void:
	$AnimationPlayer.play("Disappear")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Appear":
			$Timer.start()
		"Disappear":
			queue_free()

extends Control


var unit: Unit
var random := RandomNumberGenerator.new()
var is_line_displayed: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unit = null
	is_line_displayed = false
	random.randomize()


func can_drop_data(_position: Vector2, data) -> bool:
	var can_drop: bool = data is Unit
	return can_drop

func drop_data(_position: Vector2, data: Unit) -> void:
	$PlaceholderPortrait.hide()
	unit = data
	$Portrait.texture = load(unit.portrait)
	$CooldownTimer.start()
	
	if is_line_displayed:
		$FeaturedDialogue/AnimationPlayer.play("Disappear")

func get_random_line() -> String:
	var line_id = random.randi_range(1, 3)
	
	return tr(unit.name.to_upper() + "_FEATURED_" + str(line_id))

func display_line() -> void:
	var line = get_random_line()
	$FeaturedDialogue/Label.text = line
	# Text should be displayed at about 0.5 second per word, or at least 3 seconds total, whichever is higher
	$FeaturedDialogue/Timer.wait_time = max(3, len(line.split(" ")) * .5)
	$FeaturedDialogue.show()
	$FeaturedDialogue/AnimationPlayer.play("Appear")
	is_line_displayed = true

func _on_Timer_timeout() -> void:
	if is_line_displayed:
		$FeaturedDialogue/AnimationPlayer.play("Disappear")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name:
		"Appear":
			$FeaturedDialogue/Timer.start()
		"Disappear":
			$FeaturedDialogue.hide()
			is_line_displayed = false

func _on_CooldownTimer_timeout() -> void:
	if not is_line_displayed:
		display_line()

func _on_FeaturedUnit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		if click.button_index == BUTTON_LEFT and click.is_pressed():
			if is_line_displayed:
				$FeaturedDialogue/AnimationPlayer.play("Disappear")
			else:
				display_line()

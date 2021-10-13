extends Particles2D


func _ready() -> void:
	process_material = process_material.duplicate()

# Called when the node enters the scene tree for the first time.
func _process(_delta: float) -> void:
	if not emitting:
		queue_free()

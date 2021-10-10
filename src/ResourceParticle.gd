extends Particles2D


#const mat = preload("res://Resources/Materials/ResourceParticleMaterial.tres")

func _ready() -> void:
	process_material = process_material.duplicate()
	var mat = process_material

# Called when the node enters the scene tree for the first time.
func _process(_delta: float) -> void:
	if not emitting:
		queue_free()

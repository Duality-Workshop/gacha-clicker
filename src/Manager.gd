extends Node

var Unit = load("src/Unit.gd")

var resources = {
	"Weapons": 0,
	"Potions": 0,
	"Scrolls": 0,
	"Food": 0,
	"Blueprints": 0
}

var units


# Called when the node enters the scene tree for the first time.
func _ready():
	units = [
		Unit.new("Ferrus", "", ["Weapons"]),
		Unit.new("Lailiel", "", ["Potions"]),
		Unit.new("Saluken", "", ["Blueprints"]),
		Unit.new("Ugolya", "", ["Food"]),
		Unit.new("Ba-Yin", "", ["Scrolls"]),
		Unit.new("Morgause", "", ["Potions", "Scrolls"])
	]
	#print_debug(units)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

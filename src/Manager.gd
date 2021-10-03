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
		Unit.new("Ferrus", "", ["Weapons"], 1, 3, 3),
		Unit.new("Lailiel", "", ["Potions"], 1, 10, 10),
		Unit.new("Saluken", "", ["Blueprints"], 1, 1),
		Unit.new("Ugolya", "", ["Food"], 1, 5, 7),
		Unit.new("Ba-Yin", "", ["Scrolls"], 1, 2, 3),
		Unit.new("Morgause", "", ["Potions", "Scrolls"], 1, 1)
	]

func update_resource(resource, amount):
	get_parent().get_node("Board").get_node("ResourcesPanel").update_resource(resource, amount)

extends Node

const resource_colors = {
	"Weapons": Color(0.67451, 0.258824, 0.258824),
	"Potions": Color(0.258824, 0.67451, 0.266667),
	"Scrolls": Color(0.643137, 0.258824, 0.67451),
	"Food": Color(0.8, 0.635294, 0.141176),
	"Blueprints": Color(0.266667, 0.262745, 0.788235)
}

func get_resource_color(resource:String):
	return resource_colors["resource"]

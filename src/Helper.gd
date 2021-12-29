extends Node

enum RESOURCE_TYPE {WEAPONS, POTIONS, SCROLLS, FOOD, BLUEPRINTS, GLOBAL}

const resource_colors = {
	RESOURCE_TYPE.WEAPONS: Color(0.67451, 0.258824, 0.258824),
	RESOURCE_TYPE.POTIONS: Color(0.258824, 0.67451, 0.266667),
	RESOURCE_TYPE.SCROLLS: Color(0.643137, 0.258824, 0.67451),
	RESOURCE_TYPE.FOOD: Color(0.8, 0.635294, 0.141176),
	RESOURCE_TYPE.BLUEPRINTS: Color(0.266667, 0.262745, 0.788235)
}

static func get_resource_color(resource:int):
	return resource_colors[resource]


func get_resource_name(resource:int):
	return tr(RESOURCE_TYPE.keys()[resource])

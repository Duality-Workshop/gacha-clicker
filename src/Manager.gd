extends Node

var Unit = load("src/Unit.gd")

# resources
var resources = {
	"Weapons": 0,
	"Potions": 0,
	"Scrolls": 0,
	"Food": 0,
	"Blueprints": 0
}

# units
var units
var party = []

# nodes
var party_list
var unit_list
var resources_panel

# debug
var IS_DEBUG = !OS.has_feature("standalone")
var RANDOM = true

# signals
signal unit_updated(unit)

# Called when the node enters the scene tree for the first time.
func _ready():
	units = {
		#init(name, portrait, resources, rank = 1, cycle = 1, power = 1):
		"Ferrus": 		Unit.new("Ferrus", "", ["Weapons"], 1, 1.5, 1.5),
		"Leopold": 		Unit.new("Leopold", "", ["Weapons"], 1, 3.5, 3.25),
		"Antoinette": 	Unit.new("Antoinette", "", ["Potions"], 1, 2.6, 2.75),
		"Lailiel": 		Unit.new("Lailiel", "", ["Potions"], 1, 9.75, 9),
		"Ba-Yin": 		Unit.new("Ba-Yin", "", ["Scrolls"], 1, 1.5, 1.5),
		"Hoto": 		Unit.new("Hoto", "", ["Scrolls"], 1, 3, 3),
		"Ugolya": 		Unit.new("Ugolya", "", ["Food"], 1, 11, 10),
		"Kiki": 		Unit.new("Kiki", "", ["Food"], 1, 3.8, 3.5),
		"Saluken": 		Unit.new("Saluken", "", ["Blueprints"], 1, 3, 3),
		"Arnetta": 		Unit.new("Arnetta", "", ["Blueprints"], 1, 2.9, 3.1),
		"Morgause": 	Unit.new("Morgause", "", ["Potions", "Scrolls"], 1, 3.5, 4),
		"Benji": 		Unit.new("Benji", "", ["Weapons", "Blueprints"], 1, 2, 2.5)
	}
	
	party_list = get_parent().get_node("Board").get_node("PartyList")
	unit_list = get_parent().get_node("Board").get_node("UnitList")
	resources_panel = get_parent().get_node("Board").get_node("ResourcesPanel")
	
	if IS_DEBUG:
		#for name in units:
			#pull_unit(units[name])
		pull_unit(units["Saluken"])
		
		var p = [
			#"Ferrus",
			"Saluken",
			#"Morgause",
			#"Ba-Yin",
			#"Ugolya",
			#"Lailiel",
		]
		for u in p:
			add_to_party(u)
		
		#units["Ferrus"].rank = 30
		#units["Saluken"].rank = 29
		#units["Lailiel"].rank = 20
		#units["Morgause"].rank = 13
		#units["Ugolya"].rank = 10
		#units["Leopold"].rank = 9
		#units["Antoinette"].rank = 5
	

func add_to_party(name, id = null):
	var added_unit = units[name]
	if !id or id > len(party):
		party.append(added_unit)
	else:
		party.insert(id, added_unit)
	added_unit.party = true
	emit_signal("unit_updated", added_unit, "enlist")

func remove_from_party(name):
	var added_unit = units[name]
	party.erase(added_unit)
	added_unit.party = false
	emit_signal("unit_updated", added_unit, "remove")

func pull_unit(unit):
	# print_debug("Pulled " + unit.name + "!")
	if unit.owned:
		unit.rank += 1
		emit_signal("unit_updated", unit, "rank_up")
	else:
		unit.owned = true
		emit_signal("unit_updated", unit, "new")

func pull_random():
	var rng = RandomNumberGenerator.new()
	if RANDOM: rng.randomize()
	var k = units.keys()
	var valid_units := []
	
	for unit in units:
		if units[unit].rank < 30:
			valid_units.append(units[unit])
	
	pull_unit(valid_units[rng.randi_range(0, len(valid_units)-1)])

func get_owned_units():
	var u = []
	for unit in units:
		if units[unit].owned:
			u.append(units[unit])
	return u

func get_party():
	var u = []
	for unit in units:
		if units[unit].party:
			u.append(units[unit])
	return u

func update_resource(resource, amount):
	resources_panel.update_resource(resource, amount)

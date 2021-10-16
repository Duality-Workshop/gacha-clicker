extends Node

var Unit = load("src/Unit.gd")
var Upgrade = load("src/Upgrade.gd")

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

# upgrades
var upgrades = []
const UPGRADE_RESOURCE = {
	"Weapons": Upgrade.UpgradeResource.WEAPONS, 
	"Scrolls": Upgrade.UpgradeResource.SCROLLS, 
	"Potions": Upgrade.UpgradeResource.POTIONS, 
	"Food": Upgrade.UpgradeResource.FOOD, 
	"Blueprints": Upgrade.UpgradeResource.BLUEPRINTS
}
var base_click_power = 1

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
	
	# enum UpgradeType {DOMAIN, DEDICATION, ADDICTION}
	# enum UpgradeTarget {UNIT, CLICK, CHEST, LIMITER, GLOBAL}
	# enum UpgradeResource {WEAPONS, SCROLLS, POTIONS, FOOD, BLUEPRINTS, GLOBAL}
	# enum UpgradeScope {BASE, PERCENTAGE}
	# enum UpgradeCategory {UC, UGB, UGP, URB, URP, CGB, CGP, CRB, CRP}
	upgrades = [
		#func _init(type, target, resource, scope, power, name, description, flavour)
		Upgrade.new(Upgrade.UpgradeType.DOMAIN, Upgrade.UpgradeTarget.CLICK, Upgrade.UpgradeResource.GLOBAL, Upgrade.UpgradeScope.PERCENTAGE, 2, {"Weapons": 256, "Scrolls": 100, "Blueprints": 500}, "Basic Water Pump", "Saluken needs to use two hands and a foot to push the lever, but it’ll be worth it for simple water access. – [i]Doubles Resources per pull.[/i]", "Splishy splashy"),
		Upgrade.new(Upgrade.UpgradeType.DEDICATION, Upgrade.UpgradeTarget.UNIT, Upgrade.UpgradeResource.GLOBAL, Upgrade.UpgradeScope.BASE, 2, {"Food": 10}, "GachaFAQs Strategy Guides", "Somehow these walls of monospace text feel comforting, in addition to be pretty helpful. – [i]+2 base resource per call.[/i]", "Somebody has done the hard work before, take advantage of this."),
		
	]
	
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
		
		#units["Saluken"].upgrade_level = 3
		
		#units["Ferrus"].rank = 30
		#units["Saluken"].rank = 29
		#units["Lailiel"].rank = 20
		#units["Morgause"].rank = 13
		#units["Ugolya"].rank = 10
		#units["Leopold"].rank = 9
		#units["Antoinette"].rank = 5
		
		
		for upgrade in upgrades:
			upgrade.unlocked = true
			#upgrade.owned = true


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

func unit_add_resource(unit, resource):
	resources_panel.update_resource(resource, get_unit_resource_power(unit, resource))
	
func get_unit_resource_power(unit, resource):
	var UGB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.UGB)
	var URB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.URB, UPGRADE_RESOURCE[resource])
	var UGP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.UGP)
	var URP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.URP, UPGRADE_RESOURCE[resource])

	return (unit.power + UGB + URB) * unit.rank * UGP * URP


func get_click_power(resource=null, _raw=false):
	var CGB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CGB)
	var CRB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CRB, UPGRADE_RESOURCE[resource])
	var CGP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CGP)
	var CRP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CRP, UPGRADE_RESOURCE[resource])

	return (base_click_power + CGB + CRB) * CGP * CRP

func get_category_type(category):
	var bases = [Upgrade.UpgradeCategory.UGB, Upgrade.UpgradeCategory.URB, Upgrade.UpgradeCategory.CGB, Upgrade.UpgradeCategory.CRB]
	var percents = [Upgrade.UpgradeCategory.UGP, Upgrade.UpgradeCategory.URP, Upgrade.UpgradeCategory.CGP, Upgrade.UpgradeCategory.CRP]
	if bases.has(category):
		return Upgrade.UpgradeScope.BASE
	if percents.has(category):
		return Upgrade.UpgradeScope.PERCENTAGE
	return null

func get_upgrade_category_bonus(category, resource=null):
	var bonus = 0
	if get_category_type(category) == Upgrade.UpgradeScope.BASE:
		bonus = 0
		for upgrade in upgrades:
			if upgrade.owned and upgrade.category == category:
				if resource == null or upgrade.resource == resource:
					bonus += upgrade.power
	elif get_category_type(category) == Upgrade.UpgradeScope.PERCENTAGE:
		bonus = 1
		for upgrade in upgrades:
			if upgrade.owned and upgrade.category == category:
				if resource == null or upgrade.resource == resource:
					bonus *= upgrade.power
	return bonus

func get_unlocked_upgrades(type):
	var ups = []
	for upgrade in upgrades:
		if upgrade.type == type and upgrade.unlocked and not upgrade.owned:
			ups.append(upgrade)
	return ups

func pay(upgrade):
	for resource in upgrade.price:
		resources_panel.update_resource(resource, -upgrade.price[resource])

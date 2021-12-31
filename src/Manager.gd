extends Node

var Unit = load("src/Unit.gd")
var Upgrade = load("src/Upgrade.gd")

# resources
var resources = {}

# units
var units
var party = []
var pulls = []

# upgrades
var upgrades = {}

var base_click_power = 1
var base_chest_power = 100

# nodes
var party_list
var unit_list
var resources_panel
var dialog_manager

# debug
var IS_DEBUG = !OS.has_feature("standalone")
var RANDOM = true

# signals
signal unit_updated(unit)

# Called when the node enters the scene tree for the first time.
func _ready():
	resources = {
		Helper.RESOURCE_TYPE.WEAPONS: 0,
		Helper.RESOURCE_TYPE.SCROLLS: 0,
		Helper.RESOURCE_TYPE.POTIONS: 0,
		Helper.RESOURCE_TYPE.FOOD: 0,
		Helper.RESOURCE_TYPE.BLUEPRINTS: 0
	}
	
	units = {
		#init(name, portrait, resources, rank = 1, power = 1, cycle = 1, upgrade_level = 0, tags = []):
		"Ferrus": 		Unit.new("Ferrus", "", [Helper.RESOURCE_TYPE.WEAPONS], 1, 1.5, 1.5),
		"Leopold": 		Unit.new("Leopold", "", [Helper.RESOURCE_TYPE.WEAPONS], 1, 3.5, 3.25),
		"Antoinette": 	Unit.new("Antoinette", "", [Helper.RESOURCE_TYPE.POTIONS], 1, 2.6, 2.75),
		"Lailiel": 		Unit.new("Lailiel", "", [Helper.RESOURCE_TYPE.POTIONS], 1, 9.75, 9),
		"Ba-Yin": 		Unit.new("Ba-Yin", "", [Helper.RESOURCE_TYPE.SCROLLS], 1, 1.5, 1.5),
		"Hoto": 		Unit.new("Hoto", "", [Helper.RESOURCE_TYPE.SCROLLS], 1, 3, 3),
		"Ugolya": 		Unit.new("Ugolya", "", [Helper.RESOURCE_TYPE.FOOD], 1, 11, 10),
		"Kiki": 		Unit.new("Kiki", "", [Helper.RESOURCE_TYPE.FOOD], 1, 3.8, 3.5),
		"Saluken": 		Unit.new("Saluken", "", [Helper.RESOURCE_TYPE.BLUEPRINTS], 1, 3, 3),
		"Arnetta": 		Unit.new("Arnetta", "", [Helper.RESOURCE_TYPE.BLUEPRINTS], 1, 2.9, 3.1),
		"Morgause": 	Unit.new("Morgause", "", [Helper.RESOURCE_TYPE.POTIONS, Helper.RESOURCE_TYPE.SCROLLS], 1, 3.5, 4),
		"Benji": 		Unit.new("Benji", "", [Helper.RESOURCE_TYPE.WEAPONS, Helper.RESOURCE_TYPE.BLUEPRINTS], 1, 2, 2.5)
	}
	
	# enum UpgradeType {DOMAIN, DEDICATION, ADDICTION}
	# enum UpgradeTarget {UNIT, CLICK, CHEST, LIMITER, GLOBAL}
	# enum UpgradeResource {WEAPONS, SCROLLS, POTIONS, FOOD, BLUEPRINTS, GLOBAL}
	# enum UpgradeScope {BASE, PERCENTAGE}
	# enum UpgradeCategory {UC, UGB, UGP, URB, URP, CGB, CGP, CRB, CRP}
	upgrades = {
		#func _init(type, target, resource, scope, power, icon, name, description, flavour)
		"Water Pump": Upgrade.new(Upgrade.UpgradeType.DOMAIN, Upgrade.UpgradeTarget.CLICK, Helper.RESOURCE_TYPE.GLOBAL, Upgrade.UpgradeScope.PERCENTAGE, 2, {Helper.RESOURCE_TYPE.WEAPONS: 256, Helper.RESOURCE_TYPE.SCROLLS: 100, Helper.RESOURCE_TYPE.BLUEPRINTS: 500}, "", "Basic Water Pump", "Saluken needs to use two hands and a foot to push the lever, but it’ll be worth it for simple water access. – [i]Doubles Resources per pull.[/i]", "Splishy splashy"),
		"GachaFAQs": Upgrade.new(Upgrade.UpgradeType.DEDICATION, Upgrade.UpgradeTarget.UNIT, Helper.RESOURCE_TYPE.GLOBAL, Upgrade.UpgradeScope.BASE, 2, {Helper.RESOURCE_TYPE.FOOD: 10}, "", "GachaFAQs Strategy Guides", "Somehow these walls of monospace text feel comforting, in addition to be pretty helpful. – [i]+2 base resource per call.[/i]", "Somebody has done the hard work before, take advantage of this."),
		"Armory": Upgrade.new(Upgrade.UpgradeType.DOMAIN, Upgrade.UpgradeTarget.UNIT, Helper.RESOURCE_TYPE.WEAPONS, Upgrade.UpgradeScope.PERCENTAGE, 2, {Helper.RESOURCE_TYPE.WEAPONS: 10, Helper.RESOURCE_TYPE.BLUEPRINTS: 5}, "", "Armory", "Safety first. At least, Weapon-makers think so. With these at hand, your Units will be able to go adventuring. – [i]Weapon-makers double their Resource production. Unlocks the Treasure Chest mechanic.[/i]", ""),
		
	}
	
	party_list = get_parent().get_node("Board").get_node("UnitContainer").get_node("PartyList")
	unit_list = get_parent().get_node("Board").get_node("UnitContainer").get_node("UnitList")
	resources_panel = get_parent().get_node("Board").get_node("ResourcesPanel")
	dialog_manager = get_parent().get_node("Board").get_node("DialogManager")
	
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
		
		
		for id in upgrades:
			upgrades[id].unlocked = true
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

func unstack(timeline_name: String = "") -> void:
	if pulls:
		pull_unit(pulls[len(pulls)-1], len(pulls) > 1)

func pull_unit(unit: Unit, unstack: bool = false):
	# print_debug("Pulled " + unit.name + "!")
	if unit.owned:
		unit.rank += 1
		emit_signal("unit_updated", unit, "rank_up")
		var timeline_name = unit.name.to_upper() + "_RANK_UP"
		if unstack:
			dialog_manager.start_dialogue(timeline_name, self, "unstack")
		else:
			dialog_manager.start_dialogue(timeline_name)
	else:
		unit.owned = true
		emit_signal("unit_updated", unit, "new")
		var timeline_name = unit.name.to_upper() + "_INTRO"
		if unstack:
			dialog_manager.start_dialogue(timeline_name, self, "unstack")
		else:
			dialog_manager.start_dialogue(timeline_name)
	pulls.erase(unit)

func pull_random():
	var rng = RandomNumberGenerator.new()
	if RANDOM: rng.randomize()
	var valid_units := []
	
	for unit in units:
		if units[unit].rank + pulls.count(unit) < 30:
			valid_units.append(units[unit])
	
	pulls.append(valid_units[rng.randi_range(0, len(valid_units)-1)])

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
	
func chest_add_resource(resource):
	# print_debug(resource + ": " + str(get_chest_power(resource)))
	resources_panel.update_resource(resource, get_chest_power(resource))
	
func get_unit_resource_power(unit, resource):
	var UGB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.UGB)
	var URB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.URB, resource)
	var UGP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.UGP)
	var URP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.URP, resource)

	return (unit.power + UGB + URB) * unit.rank * UGP * URP


func get_click_power(resource=null, _raw=false):
	var CGB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CGB)
	var CRB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CRB, resource)
	var CGP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CGP)
	var CRP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CRP, resource)

	return (base_click_power + CGB + CRB) * CGP * CRP


func get_chest_power(resource=null, _raw=false):
	var HGB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.HGB)
	var HRB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.HRB, resource)
	var HGP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.HGP)
	var HRP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.HRP, resource)

	return (base_chest_power + HGB + HRB) * HGP * HRP

func get_category_type(category):
	var bases = [Upgrade.UpgradeCategory.UGB, Upgrade.UpgradeCategory.URB, Upgrade.UpgradeCategory.CGB, Upgrade.UpgradeCategory.CRB, Upgrade.UpgradeCategory.HGB, Upgrade.UpgradeCategory.HRB]
	var percents = [Upgrade.UpgradeCategory.UGP, Upgrade.UpgradeCategory.URP, Upgrade.UpgradeCategory.CGP, Upgrade.UpgradeCategory.CRP, Upgrade.UpgradeCategory.HGP, Upgrade.UpgradeCategory.HRP]
	if bases.has(category):
		return Upgrade.UpgradeScope.BASE
	if percents.has(category):
		return Upgrade.UpgradeScope.PERCENTAGE
	return null

func get_upgrade_category_bonus(category, resource=null):
	var bonus = 0
	if get_category_type(category) == Upgrade.UpgradeScope.BASE:
		bonus = 0
		for id in upgrades:
			var upgrade = upgrades[id]
			if upgrade.owned and upgrade.category == category:
				if resource == null or upgrade.resource == resource:
					bonus += upgrade.power
	elif get_category_type(category) == Upgrade.UpgradeScope.PERCENTAGE:
		bonus = 1
		for id in upgrades:
			var upgrade = upgrades[id]
			if upgrade.owned and upgrade.category == category:
				if resource == null or upgrade.resource == resource:
					bonus *= upgrade.power
	return bonus

func get_unlocked_upgrades(type):
	var ups = []
	for id in upgrades:
		var upgrade = upgrades[id]
		if upgrade.type == type and upgrade.unlocked and not upgrade.owned:
			ups.append(upgrade)
	return ups

func pay(upgrade):
	for resource in upgrade.price:
		resources_panel.update_resource(resource, -upgrade.price[resource])


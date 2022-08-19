extends Node

var Unit = load("src/Unit.gd")
var Upgrade = load("src/Upgrade.gd")

# resources
var resources = {}

# units
var units = {}
var party = []
var reserve = []
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
var pull_window
var shop_window

# data
var slot = "res://Saves/1.json"

# flags
var is_dragging := false

# debug
var IS_DEBUG = !OS.has_feature("standalone")
var RANDOM = true

# signals
signal unit_updated(unit)

# Load basic data on title screen
func _ready() -> void:
	# Setup standard game data
	resources = {
		Helper.RESOURCE_TYPE.TOOLS: 0,
		Helper.RESOURCE_TYPE.SCROLLS: 0,
		Helper.RESOURCE_TYPE.POTIONS: 0,
		Helper.RESOURCE_TYPE.FOOD: 0,
		Helper.RESOURCE_TYPE.BLUEPRINTS: 0
	}
	
	setup_tags()
	setup_units()
	setup_upgrades()
	
	# enum UpgradeType {DOMAIN, DEDICATION, ADDICTION}
	# enum UpgradeTarget {UNIT, CLICK, CHEST, LIMITER, GLOBAL}
	# enum UpgradeResource {TOOLS, SCROLLS, POTIONS, FOOD, BLUEPRINTS, GLOBAL}
	# enum UpgradeScope {BASE, PERCENTAGE}
	# enum UpgradeCategory {UC, UGB, UGP, URB, URP, CGB, CGP, CRB, CRP}
#	upgrades = {
#		#func _init(type, target, resource, scope, power, icon, name, description, flavour)
#		"Water Pump": Upgrade.new(Upgrade.UpgradeType.DOMAIN, Upgrade.UpgradeTarget.CLICK, Helper.RESOURCE_TYPE.GLOBAL, Upgrade.UpgradeScope.PERCENTAGE, 2, {Helper.RESOURCE_TYPE.TOOLS: 256, Helper.RESOURCE_TYPE.SCROLLS: 100, Helper.RESOURCE_TYPE.BLUEPRINTS: 500}, "", "Basic Water Pump", "Saluken needs to use two hands and a foot to push the lever, but it’ll be worth it for simple water access. – [i]Doubles Resources per pull.[/i]", "Splishy splashy"),
#		"GachaFAQs": Upgrade.new(Upgrade.UpgradeType.DEDICATION, Upgrade.UpgradeTarget.UNIT, Helper.RESOURCE_TYPE.GLOBAL, Upgrade.UpgradeScope.BASE, 2, {Helper.RESOURCE_TYPE.FOOD: 10}, "", "GachaFAQs Strategy Guides", "Somehow these walls of monospace text feel comforting, in addition to be pretty helpful. – [i]+2 base resource per call.[/i]", "Somebody has done the hard work before, take advantage of this."),
#		"Armory": Upgrade.new(Upgrade.UpgradeType.DOMAIN, Upgrade.UpgradeTarget.UNIT, Helper.RESOURCE_TYPE.TOOLS, Upgrade.UpgradeScope.PERCENTAGE, 2, {Helper.RESOURCE_TYPE.TOOLS: 10, Helper.RESOURCE_TYPE.BLUEPRINTS: 5}, "", "Armory", "Safety first. At least, Weapon-makers think so. With these at hand, your Units will be able to go adventuring. – [i]Weapon-makers double their Resource production. Unlocks the Treasure Chest mechanic.[/i]", ""),
#
#	}

# Called from Board once it is loaded.
func start():
	var parent = get_parent().get_node("Board")
	party_list = parent.get_node("UnitContainer").get_node("PartyList")
	unit_list = parent.get_node("UnitContainer").get_node("UnitList")
	resources_panel = parent.get_node("ResourcesPanel")
	dialog_manager = parent.get_node("DialogManager")
	pull_window = parent.get_node("TagPullWindow")
	shop_window = parent.get_node("ShopButton").get_node("ShopWindow").get_node("HBoxContainer").get_node("TabContainer")
	
	load_save_file()
	
	unlock_upgrades()
	shop_window.update()
	
	var err
	err = connect("unit_updated", unit_list, "_on_unit_updated")
	if err: push_error("Couldn't connect signal unit_updated to unit_list!")
	err = connect("unit_updated", party_list, "_on_unit_updated")
	if err: push_error("Couldn't connect signal unit_updated to party_list!")
	
	unit_list.start()
	party_list.start()
	
	if IS_DEBUG:
		#for name in units:
			#pull_unit(units[name])
		#pull_unit(units[13])
		
		#var p = [
			#"Ferrus",
		#	13, # Saluken
			#"Morgause",
			#"Ba-Yin",
			#"Ugolya",
			#"Lailiel",
		#]
		#for u in p:
		#	add_to_party(u)
		
		#units["Saluken"].upgrade_level = 3
		
		#units["Ferrus"].rank = 30
		#units["Saluken"].rank = 29
		#units["Lailiel"].rank = 20
		#units["Morgause"].rank = 13
		#units["Ugolya"].rank = 10
		#units["Leopold"].rank = 9
		#units["Antoinette"].rank = 5
		
		
#		for id in upgrades:
#			upgrades[id].unlocked = true
#			#upgrade.owned = true
		
		pass


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.pressed and is_dragging:
		is_dragging = false

# Load data from save file currently selected in slot
func load_save_file() -> void:
	# Retrieve save file
	var save_file = File.new()
	var err = save_file.open(slot, File.READ)
	if err:
		push_error("Couldn't open save file " + slot)
	# Parse file
	var save_data = JSON.parse(save_file.get_as_text())
	save_file.close()
	
	# Check integrity
	if save_data.error:
		push_error("Error while parsing save file " + slot + ". " + save_data.error_string + " at line " + str(save_data.error_line))
	
	if typeof(save_data.result) != TYPE_DICTIONARY:
		push_error("Invalid save data structure")
	
	# Load data
	var result = save_data.result
	for unit in result["units"]:
		load_unit(int(unit), result["units"][unit])
	
	for unit in result["party"]:
		add_to_party(int(unit))
	
	for unit in result["calls"]["awaiting"]:
		pulls.append(units[int(unit)])
		
	resources = {
		Helper.RESOURCE_TYPE.TOOLS: result["resources"]["owned"]["tools"],
		Helper.RESOURCE_TYPE.SCROLLS: result["resources"]["owned"]["scrolls"],
		Helper.RESOURCE_TYPE.POTIONS: result["resources"]["owned"]["potions"],
		Helper.RESOURCE_TYPE.FOOD: result["resources"]["owned"]["food"],
		Helper.RESOURCE_TYPE.BLUEPRINTS: result["resources"]["owned"]["blueprints"]
	}

func save() -> void:
	var units_owned = {}
	for unit in get_owned_units():
		units_owned[unit.id] = unit.rank
	
	var units_awaiting = []
	for unit in pulls:
		units_awaiting.append(unit.id)
	
	var units_in_party = []
	for unit in get_party():
		units_in_party.append(unit.id)
	
	var save_data = {
		"resources": {
			"owned":{
				"tools": resources[Helper.RESOURCE_TYPE.TOOLS],
				"potions": resources[Helper.RESOURCE_TYPE.POTIONS],
				"scrolls": resources[Helper.RESOURCE_TYPE.SCROLLS],
				"food": resources[Helper.RESOURCE_TYPE.FOOD],
				"blueprints": resources[Helper.RESOURCE_TYPE.BLUEPRINTS]
				},
			"produced":{
				"tools": 0,
				"potions": 0,
				"scrolls": 0,
				"food": 0,
				"blueprints": 0
				}
		},
		"units": units_owned,
		"upgrades": [],
		"callerite": {
			"owned": 0,
			"used": 0
		},
		"curserite": {
			"owned": 0,
			"used": 0
		},
		"calls": {
			"made": 0,
			"awaiting": units_awaiting
		},
		"flags": {},
		"domain_name": "",
		"leader_name": "",
		"featured_unit": 0,
		"party": units_in_party,
		"settings": {},
		"version": "1.0.0"
	}
	
	var save_file = File.new()
	var err = save_file.open(slot, File.WRITE)
	if err:
		push_error("Couldn't open save file " + slot)
	# Write file
	save_file.store_string(JSON.print(save_data, "\t"))
	save_file.close()


# Read tag data CSV and populate Manager's tag dictionnary
func setup_tags() -> void:
	var csv_filename = "res://Data/tags.csv"
	var csv_file = File.new()
	var err = csv_file.open(csv_filename, File.READ)
	
	if err:
		push_error("Couldn't open unit data CSV!")
	
	csv_file.get_csv_line() # skip header line
	
	var tags_dict = {}
	while not csv_file.eof_reached():
		# CSV structure: id, name, category
		var tag_info = csv_file.get_csv_line()
		if not tag_info[2] in tags_dict:
			tags_dict[tag_info[2]] = {tag_info[0]: tag_info[1]}
		else:
			tags_dict[tag_info[2]][tag_info[0]] = tag_info[1]


# Read unit data CSV and populate Manager's unit dictionnary
func setup_units() -> void:
	var csv_filename = "res://Data/unit_stats.csv"
	var csv_file = File.new()
	var err = csv_file.open(csv_filename, File.READ)
	
	if err:
		push_error("Couldn't open unit data CSV!")
	
	csv_file.get_csv_line() # skip header line
	
	while not csv_file.eof_reached():
		# CSV structure: id, name, resources, power, cycle, tags
		var unit_info = csv_file.get_csv_line()
		if unit_info[1] == "unnamed":
			continue
		
		var unit_resources = []
		
		var unit_name:String = unit_info[1]
		var unit_tags = unit_info[5].split(",", false)
		
		for res in unit_info[2].split(",", false):
			unit_resources.append(Helper.get_resource_type(res))
		
		#init(id, name, portrait, resources, power, cycle, tags = [], rank = 1, upgrade_level = 0)
		units[int(unit_info[0])] = Unit.new(int(unit_info[0]), unit_name, "res://Resources/Portraits/" + unit_name.to_lower() + " - 1 (neutral).png", unit_resources, float(unit_info[3]), float(unit_info[4]), unit_tags)

func setup_upgrades() -> void:
	var csv_filename = "res://Data/upgrades.csv"
	var csv_file = File.new()
	var err = csv_file.open(csv_filename, File.READ)
	
	if err:
		push_error("Couldn't open upgrade data CSV!")
	
	csv_file.get_csv_line() # skip header line
	
	var types = {
		"DOMAIN": Upgrade.UpgradeType.DOMAIN,
		"DEDICATION": Upgrade.UpgradeType.DEDICATION,
		"ADDICTION": Upgrade.UpgradeType.ADDICTION
	}
	
	var targets = {
		"UNIT": Upgrade.UpgradeTarget.UNIT,
		"CLICK": Upgrade.UpgradeTarget.CLICK,
		"CHEST": Upgrade.UpgradeTarget.CHEST,
		"LIMITER": Upgrade.UpgradeTarget.LIMITER,
		"FEATURE": Upgrade.UpgradeTarget.FEATURE
	}
	
	var t_resources = {
		"GLOBAL": Helper.RESOURCE_TYPE.GLOBAL,
		"TOOLS": Helper.RESOURCE_TYPE.TOOLS,
		"SCROLLS": Helper.RESOURCE_TYPE.SCROLLS,
		"POTIONS": Helper.RESOURCE_TYPE.POTIONS,
		"FOOD": Helper.RESOURCE_TYPE.FOOD,
		"BLUEPRINTS": Helper.RESOURCE_TYPE.BLUEPRINTS
	}
	
	var scopes = {
		"PERCENTAGE": Upgrade.UpgradeScope.PERCENTAGE,
		"BASE": Upgrade.UpgradeScope.BASE
	}
	
	while not csv_file.eof_reached():
		var upgrade_info = csv_file.get_csv_line()
		
		var upgrade = {}
		upgrade["id"] = int(upgrade_info[0])
		upgrade["name"] = upgrade_info[1]
		upgrade["tier"] = int(upgrade_info[2])
		upgrade["type"] = types[upgrade_info[3]]
		upgrade["target"] = targets[upgrade_info[4]]
		upgrade["resource"] = t_resources[upgrade_info[5]] if upgrade_info[5] else "NA"
		upgrade["scope"] = scopes[upgrade_info[6]] if upgrade_info[6] else "NA"
		upgrade["power"] = float(upgrade_info[7]) if upgrade_info[7] else 0.0
		upgrade["icon"] = upgrade_info[8]
		upgrade["price"] = {
			Helper.RESOURCE_TYPE.TOOLS: Helper.cell_to_int(upgrade_info[9]),
			Helper.RESOURCE_TYPE.SCROLLS: Helper.cell_to_int(upgrade_info[10]),
			Helper.RESOURCE_TYPE.POTIONS: Helper.cell_to_int(upgrade_info[11]),
			Helper.RESOURCE_TYPE.FOOD: Helper.cell_to_int(upgrade_info[12]),
			Helper.RESOURCE_TYPE.BLUEPRINTS: Helper.cell_to_int(upgrade_info[13])
		}
		
		if upgrade_info[14] == "":
			upgrade["unlock_condition"] = {}
		else:
			var unlock_split = upgrade_info[14].split(";")
			var unlocks = {}
			for group in unlock_split:
				var group_split = group.split(":")
				var ids = group_split[1].split(",")
				var ids_int = []
				for id in ids:
					ids_int.append(int(id))
				
				unlocks[group_split[0]] = ids_int
			
			upgrade["unlock_condition"] = unlocks
		
		upgrade["desc"] = upgrade_info[15]
		upgrade["effect"] = upgrade_info[16]
		upgrade["flavour"] = upgrade_info[17]
		
		#id,name,tier,type,target,resource,scope,power,icon,price_tools,price_potions,price_scrolls,price_food,price_blueprints,unlock_conditions,description,effect,flavour
		#func _init(u_type, u_target, u_resource, u_scope, u_power:float, u_price, u_icon:String, 
		#			u_name:String, u_description:String, u_flavour="") -> void:
		upgrades[int(upgrade_info[0])] = Upgrade.new(
			upgrade["id"],
			upgrade["tier"],
			upgrade["type"],
			upgrade["target"],
			upgrade["price"],
			upgrade["icon"],
			upgrade["name"],
			upgrade["desc"],
			upgrade["effect"],
			upgrade["unlock_condition"],
			upgrade["resource"],
			upgrade["scope"],
			upgrade["power"],
			upgrade["flavour"]
		)


func load_unit(id, rank) -> void:
	units[id].owned = true
	units[id].rank = int(rank)
	reserve.append(units[id])


func add_to_party(id, party_slot = null) -> void:
	# Retrieve the unit
	var added_unit = units[id]
	
	# Check if we're out of bounds
	if party_slot == null or party_slot > len(party):
		party.append(added_unit)
	else:
		party.insert(party_slot, added_unit)
	
	added_unit.party = true
	reserve.erase(added_unit)
	
	emit_signal("unit_updated", added_unit, "enlist")

func remove_from_party(id, reserve_slot = null) -> void:
	# Retrieve the unit
	var added_unit = units[id]
	
	# Check if we're out of bounds
	if reserve_slot == null or reserve_slot > len(reserve):
		reserve.append(added_unit)
	else:
		reserve.insert(reserve_slot, added_unit)
	
	party.erase(added_unit)
	added_unit.party = false
	
	emit_signal("unit_updated", added_unit, "remove")

func reorder_unit(id, unit_slot) -> void:
	# Retrieve the unit
	var added_unit = units[id]
	var target_slot
	
	if get_unit_index(id) >= unit_slot:
		target_slot = unit_slot
	else:
		target_slot = unit_slot - 1
	
	if added_unit.party:
		party.erase(added_unit)
		if unit_slot == -1:
			party.append(added_unit)
		else:
			party.insert(target_slot, added_unit)
	else:
		reserve.erase(added_unit)
		if unit_slot == -1:
			reserve.append(added_unit)
		else:
			reserve.insert(target_slot,added_unit)
	
	emit_signal("unit_updated", added_unit, "reorder")

func unstack(_timeline_name: String = "") -> void:
	if pulls:
		pull_unit(pulls[0], len(pulls) > 0)

func pull_unit(unit: Unit, unstack: bool = false):
	# print_debug("Pulled " + unit.name + "!")
	if unit.owned:
		unit.rank += 1
		emit_signal("unit_updated", unit, "rank_up")
		var timeline_name = unit.name.to_upper() + "_RANK_UP"
		if unstack and len(pulls) > 1:
			dialog_manager.start_dialogue(timeline_name, self, "unstack")
		else:
			dialog_manager.start_dialogue(timeline_name)
	else:
		unit.owned = true
		reserve.append(unit)
		emit_signal("unit_updated", unit, "new")
		var timeline_name = unit.name.to_upper() + "_INTRO"
		if unstack and len(pulls) > 1:
			dialog_manager.start_dialogue(timeline_name, self, "unstack")
		else:
			dialog_manager.start_dialogue(timeline_name)
	
	if unstack:
		pulls.erase(unit)

func pull_random():
	var rng = RandomNumberGenerator.new()
	if RANDOM: rng.randomize()
	var valid_units := get_pullable_units()
	
	pulls.append(valid_units[rng.randi_range(0, len(valid_units)-1)])

func get_pullable_units() -> Array:
	var valid_units := []
	
	for unit in units:
		if units[unit].rank + pulls.count(unit) < 30:
			valid_units.append(units[unit])
	
	return valid_units

func get_owned_units() -> Array:
	var u = []
	for unit in units:
		if units[unit].owned:
			u.append(units[unit])
	return u

func get_party() -> Array:
	var u = []
	for unit in units:
		if units[unit].party:
			u.append(units[unit])
	return u

func get_unit_index(id:int) -> int:
	if units[id].party:
		return party.find(units[id])
	else:
		return reserve.find(units[id])

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

	return (unit.power + UGB + URB) * unit.rank * pow(2, UGP + URP - 2)
	# -2 because we only want to count extra percentage levels


func get_click_power(resource=null, _raw=false):
	var CGB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CGB)
	var CRB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CRB, resource)
	var CGP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CGP)
	var CRP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.CRP, resource)

	return (base_click_power + CGB + CRB) * pow(2, CGP + CRP - 2)
	# -2 because we only want to count extra percentage levels


func get_chest_power(resource=null, _raw=false):
	var HGB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.HGB)
	var HRB = get_upgrade_category_bonus(Upgrade.UpgradeCategory.HRB, resource)
	var HGP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.HGP)
	var HRP = get_upgrade_category_bonus(Upgrade.UpgradeCategory.HRP, resource)

	return (base_chest_power + HGB + HRB) * pow(2, HGP + HRP - 2)
	# -2 because we only want to count extra percentage levels

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

func get_unlocked_upgrades(type, return_ids=false):
	var ups = []
	for id in upgrades:
		var upgrade = upgrades[id]
		if upgrade.type == type and upgrade.unlocked and not upgrade.owned:
			if return_ids:
				ups.append(id)
			else:
				ups.append(upgrade)
	return ups

func unlock_upgrades() -> void:
	for id in upgrades:
		var upgrade = upgrades[id]
		if not upgrade.owned:
			var unlock = true
			
			for unlock_type in upgrade.unlock_conditions:
				# TODO: manage other unlock types
				if unlock_type == "UPGRADE":
					for upgrade_id in upgrade.unlock_conditions[unlock_type]:
						if not upgrades[upgrade_id].owned:
							unlock = false
							break
			
			if unlock:
				upgrade.unlocked = true

func pay(upgrade):
	upgrade.owned = true
	FlagManager.call_upgrade_flag(upgrade.id)
	for resource in upgrade.price:
		resources_panel.update_resource(resource, -upgrade.price[resource])
	
	unlock_upgrades()
	shop_window.update()

func open_pull_window(success_chance, _target) -> void:
	pull_window.get_node("VBoxContainer/Label").text = tr("SUCCESS_CHANCES") + ": " + str(success_chance * 100) + "%"
	pull_window.odds = success_chance
	pull_window.popup()

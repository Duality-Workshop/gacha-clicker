extends Object

class_name Unit

var id
var name
var portrait
var rank
var upgrade_level
var resources
var cycle
var power
var party
var owned
var tags

const UPGRADE_FACTOR = [1, .90, .65, .15] # -10%, -25%, -50%

func _init(id, name, portrait, resources, power, cycle, tags = [], rank = 1, upgrade_level = 0):
	self.id = id
	self.name = name
	self.portrait = portrait
	self.resources = resources
	self.power = power
	self.cycle = cycle
	self.tags = tags
	self.rank = rank
	self.upgrade_level = upgrade_level
	self.party = false
	self.owned = false


func get_cycle():
	return cycle * UPGRADE_FACTOR[upgrade_level]


func _to_string():
	return JSON.print({
		"name": name,
		"portrait": portrait,
		"rank": rank,
		"resources": resources,
		"cycle": cycle,
		"power": power,
		"party": party,
		"owned": owned,
		"tags": tags
	})

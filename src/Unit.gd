extends Object

class_name Unit

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

const UPGRADE_FACTOR = [1, .90, .65, .15]

func _init(name, portrait, resources, rank = 1, power = 1, cycle = 1, upgrade_level = 0, tags = []):
	self.name = name
	self.portrait = portrait
	self.rank = rank
	self.upgrade_level = upgrade_level
	self.resources = resources
	self.cycle = cycle
	self.power = power
	self.party = false
	self.owned = false
	self.tags = tags


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

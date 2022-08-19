extends Object

class_name Unit

var id
var name: String
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

func _init(_id, _name, _portrait, _resources, _power, _cycle, _tags = [], _rank = 1, _upgrade_level = 0):
	self.id = _id
	self.name = _name
	self.portrait = _portrait
	self.resources = _resources
	self.power = _power
	self.cycle = _cycle
	self.tags = _tags
	self.rank = _rank
	self.upgrade_level = _upgrade_level
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

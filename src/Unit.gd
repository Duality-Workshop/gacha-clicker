extends Object

class_name Unit

var name
var portrait
var rank
var resources
var cycle
var power
var party
var owned


func _init(name, portrait, resources, rank = 1, power = 1, cycle = 1):
	self.name = name
	self.portrait = portrait
	self.rank = rank
	self.resources = resources
	self.cycle = cycle
	self.power = power
	self.party = false
	self.owned = false

func _to_string():
	return JSON.print({
		"name": name,
		"portrait": portrait,
		"rank": rank,
		"resources": resources,
		"cycle": cycle,
		"power": power,
		"party": party,
		"owned": owned
	})

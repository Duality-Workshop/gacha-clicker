extends Object

class_name Upgrade

enum UpgradeType {DOMAIN, DEDICATION, ADDICTION}
enum UpgradeTarget {UNIT, CLICK, CHEST, LIMITER, GLOBAL}
#enum Helper.RESOURCE_TYPE {WEAPONS, SCROLLS, POTIONS, FOOD, BLUEPRINTS, GLOBAL}
enum UpgradeScope {BASE, PERCENTAGE}
enum UpgradeCategory {UGB, UGP, URB, URP, CGB, CGP, CRB, CRP, HGB, HGP, HRB, HRP}
enum UnlockConditionType {UPGRADE, TIER, INTERACTION, UNIT}
# TODO: chance?

var type
var target
var resource
var scope
var power : float
var name : String
var description : String
var flavour : String
var icon : String
var owned : bool
var unlocked : bool
var category
var price := {}

func _init(u_type, u_target, u_resource, u_scope, u_power:float, u_price, u_icon:String, u_name:String, u_description:String, u_flavour="") -> void:
	type = u_type
	target = u_target
	resource = u_resource
	scope = u_scope
	power = u_power
	icon = u_icon
	name = u_name
	description = u_description
	flavour = u_flavour
	price = u_price
	unlocked = false
	
	if target == UpgradeTarget.UNIT:
		if resource == Helper.RESOURCE_TYPE.GLOBAL:
			if scope == UpgradeScope.BASE:
				category = UpgradeCategory.UGB
			else:
				category = UpgradeCategory.UGP
		else:
			if scope == UpgradeScope.BASE:
				category = UpgradeCategory.URB
			else:
				category = UpgradeCategory.URP
	elif target == UpgradeTarget.CLICK:
		if resource == Helper.RESOURCE_TYPE.GLOBAL:
			if scope == UpgradeScope.BASE:
				category = UpgradeCategory.CGB
			else:
				category = UpgradeCategory.CGP
		else:
			if scope == UpgradeScope.BASE:
				category = UpgradeCategory.CRB
			else:
				category = UpgradeCategory.CRP
	elif target == UpgradeTarget.CHEST:
		if resource == Helper.RESOURCE_TYPE.GLOBAL:
			if scope == UpgradeScope.BASE:
				category = UpgradeCategory.HGB
			else:
				category = UpgradeCategory.HGP
		else:
			if scope == UpgradeScope.BASE:
				category = UpgradeCategory.HRB
			else:
				category = UpgradeCategory.HRP
	else:
		category = null

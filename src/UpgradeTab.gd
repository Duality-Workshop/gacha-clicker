extends ScrollContainer

export (String) var tab_name
var Upgrade = load("res://src/Upgrade.gd")
export(Upgrade.UpgradeType) var type

var upgrade_panel = preload("res://Scenes/UpgradePanel.tscn")

# Called when the node enters the scene tree for the first time.
func update() -> void:
	for n in $UpgradeList.get_children():
		$UpgradeList.remove_child(n)
		n.queue_free()
	
	for upgrade in Manager.get_unlocked_upgrades(type):
		var panel_instance = upgrade_panel.instance()
		panel_instance.init(upgrade)
		$UpgradeList.add_child(panel_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

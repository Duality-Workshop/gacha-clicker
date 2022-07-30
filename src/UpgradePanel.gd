extends PanelContainer

var upgrade
var price_node = preload("res://Scenes/UpgradePrice.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ignore_mouse(get_children())
	

func ignore_mouse(nodes) -> void:
	for node in nodes:
		ignore_mouse(node.get_children())
		node.mouse_filter = MOUSE_FILTER_IGNORE

func init(_upgrade) -> void:
	self.upgrade = _upgrade
	$MarginBox/HBoxContainer/Text/Name.text = upgrade.name
	$MarginBox/HBoxContainer/Text/Description.bbcode_text = upgrade.description + " - " + upgrade.effect
	$MarginBox/HBoxContainer/Text/Flavour.text = upgrade.flavour
	
	for resource in upgrade.price:
		if upgrade.price[resource] > 0:
			var node = price_node.instance()
			node.get_node("Resource").color = Helper.get_resource_color(resource)
			node.resource = resource
			node.get_node("Amount").text = str(upgrade.price[resource])
			$MarginBox/HBoxContainer/Price.add_child(node)

func is_affordable() -> bool:
	for price in $MarginBox/HBoxContainer/Price.get_children():
		if not price.is_affordable():
			return false
	return true

func _on_UpgradePanel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and is_affordable():
			Manager.pay(upgrade)
			queue_free()

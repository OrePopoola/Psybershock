extends Node
###Testing equipment code ~ GROK

var equipped_weapon : Dictionary = {}   # the item that is currently equipped
var equipped_weapon_node : Node3D = null   # the 3D model that is attached to the player

signal equipment_changed   # optional – UI can listen to it


var Inventory = []
signal inventory_updated

var player_node = null
@onready var inventory_slot_scene = preload("res://Global/inventory_slot.tscn")
@onready var player = get_tree().get_first_node_in_group("Player")

@onready var soup_slots = []
@export var speed = 200

var hotbar_size = 4
var hotbar_inventory = []


func _ready():
	Global.set_player_reference(player)
	print(player)
	Inventory.resize(15)
	hotbar_inventory.resize(hotbar_size)
	soup_slots = hotbar_inventory
func get_input():
	var input_direction = Input.get_vector("Move Left","Move Right","Move Up","Move Down")	
	
func add_item(item, to_hotbar = false):
	var added_to_hotbar = false
	# add to hotbar
	if to_hotbar:
		added_to_hotbar = add_hotbar_item(item)
		inventory_updated.emit()
	if not added_to_hotbar:
		for i in range(Inventory.size()):
			if Inventory[i] != null and Inventory[i]["type"] == item["type"] and Inventory[i]["name"] == item["name"]:
				Inventory[i]["quantity"] += item["quantity"]
				inventory_updated.emit()
				print("Item stack incremented")
				return true
			elif Inventory[i] == null:
				Inventory[i] = item
				inventory_updated.emit()
				print("new Item added")
				return true
func remove_item(item_name, item_effect):
#might need to add exception for hotbar
	print("entering remove item")
	print("Item Name", item_name)
	print("Item effect", item_effect)
	
	for i in range(Inventory.size()):
		if Inventory[i] != null:
			print(Inventory[i]["name"])
		if Inventory[i] != null and Inventory[i]["name"] == item_name and Inventory[i]["effect"] == item_effect:
			Inventory[i]["quantity"] -= 1
			print("removing +" + str(Inventory[i]["name"]))
			print("quant" + str(Inventory[i]["quantity"]))
			if Inventory[i]["quantity"] <= 0:
				Inventory[i] = null
				print("removing item")
			inventory_updated.emit()
			return true
	return false
	
func increase_inventory_size():
	inventory_updated.emit()
func set_player_reference(player):
	player_node = player
func adjust_drop_position(position):
	var radius = 5
	var nearby_items = get_tree().get_nodes_in_group("Items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector2(randf_range(-radius,radius), randf_range(-radius,radius))
			position += random_offset
			break
	return position
	
	
# TO CHANGE DROP POSITION GO TO DROP OFFSET IN THE INVENTORY SLOT FUNCTION
func drop_item(item_data,drop_position):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_instance.set_item_data(item_data)
	#drop_position = adjust_drop_position(drop_position)
	item_instance.global_position = drop_position
	get_tree().current_scene.add_child(item_instance)
func add_hotbar_item(item):
	for i in range(hotbar_size):
		if hotbar_inventory[i] == null:
			hotbar_inventory[i] = item
			return true
	return false
func remove_hotbar_item(item_type, item_effect):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null and hotbar_inventory[i]["type"] == item_type and hotbar_inventory[i]["effect"] == item_effect:
			if hotbar_inventory[i]["quantity"] <= 0:
				hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false
func unassign_hotbar_item(item_type, item_effect):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null and hotbar_inventory[i]["type"] == item_type and hotbar_inventory[i]["effect"] == item_effect:
			hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false
func is_item_assigned_to_hotbar(item_to_check):
	return item_to_check in hotbar_inventory
				
func swap_inventory_items(index1, index2):
	if index1 < 0 or index1 > Inventory.size() or index2 < 0 or index2 > Inventory.size():
		return false
		
	var temp = Inventory[index1]
	Inventory[index1] = Inventory[index2]
	Inventory[index2] = temp
	inventory_updated.emit()
	return true

func swap_hotbar_items(index1, index2):
	if index1 < 0 or index1 > hotbar_inventory.size() or index2 < 0 or index2 > hotbar_inventory.size():
		return false
		
	var temp = hotbar_inventory[index1]
	hotbar_inventory[index1] = hotbar_inventory[index2]
	hotbar_inventory[index2] = temp
	inventory_updated.emit()
	return true

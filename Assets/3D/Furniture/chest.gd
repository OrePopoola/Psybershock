extends Node3D
# check if chest is opened and if player presses interact to get the item out of it, a crowbar in this case.

var has_content = true
@onready var gate3D = $Gate3D
@onready var key_itemName = $Key
@onready var opened = $Opened.visible
#@export var rewards : Node3D
@export var reward_data : Dictionary
# this should be an inventoryItem
#maybe select an item as a gift
#@export var reward_sword : Sprite3D
@onready var player = get_tree().get_first_node_in_group("Player")
#var reward_data
var key_data

#TODO: delete key from inventory
#
@onready var key = $Key
@export var key_item_type : String
@export var key_item_name	:String
@export var key_item_effect :String
@export var locked_text : Array[String] 
@export var unlocked_text : Array[String] = []# Just change to string to go back to normal
@export var inventoryItem : Node3D 
var has_key = false
func _ready() -> void:
	gate3D.locked_text = locked_text
	gate3D.unlocked_text = unlocked_text
	gate3D.inventoryItem = key_itemName
	#Unlocked option detected by opened variable
	if reward_data == null:
		reward_data = {
	"name"       : "Crowbar",
	"type"       : "weapon",
	"texture"    : "res://Assets/Art/equipment/crowbar.png",
	"quantity"   : 1,
	"effect"     : "",               # not used for weapons
	"scene"      : "",   # <-- 3D model
	"swing_style": "sword",          # optional, defaults to "sword"
	"damage"     : 4
}
	key_data = {
		"quantity" : 1,
		"type" : key_itemName.item_type,
		"name" : key_itemName,
		"texture" : key_itemName.item_texture,
		"effect" : key_item_effect,
		"scene_path" : key_itemName.scene_path,
	}
	#will ned a reward array
var player_in_range = false

func recheck():
	var found = false
	if has_key == true:	
		for i in range(Global.Inventory.size()):
				if Global.Inventory[i] != null and Global.Inventory[i]["name"] == key_item_name and Global.Inventory[i]["quantity"] > 0 :
					found = true
		if found == false:
			has_key = false
			
func _process(delta: float) -> void:
	#opened = gate3D.unlocked
	#if opened == true:
	#print(has_key)
	recheck()
	if has_key == false:
		for i in range(Global.Inventory.size()):
			if Global.Inventory[i] != null and Global.Inventory[i]["name"] == key_item_name: 
				has_key = true
				
	if has_key and player_in_range and has_content and Input.is_action_just_pressed("Interact"):
		opened = true
		#gate3D.unlocked = true
		print("adding reward!")
		Global.add_item(reward_data)
		#Global.equipped_weapon = reward_data
		print(key_data)
		Global.remove_item(key_item_name,key_item_effect)
		#TODO: Support for multiple items
		print("item dropped")
		$Opened.visible = true
		$Unopened.visible = false
		has_content =false
		has_key = false
		
	#if opened == true and player_in_range and has_content == true and Input.is_action_pressed("Interact"):
#		print("Success!... Or is it?")
	#	Global.add_item(reward_data)
	#	Global.remove_item(key_data["name"],key_data["effect"])
	#	#TODO: Support for multiple items
	#	print("item dropped")
	#	has_content =false
		

		


func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body.is_in_group("Player"):
		print(" Hello, detected by chest")
		player_in_range = true
		gate3D.player_in_range = true
	#if body.is_in_group("Player")and Input.is_action_pressed("Interact") and !opened:
		#print("you are interacting")
		#player_in_range = true
		#gate3D.player_in_range = true
		#print("checking the gate")
	#if opened == true and body.is_in_group("Player"):
		##TODO: Rewarding sword objects
		#body.has_sword = true
		#body.sword_sprite.visible = true
		#body.sword_sprite = reward_sword
		#print("changed sword")
		#print("assigning texture")
	


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		gate3D.player_in_range = false


#func _on_chest_area_3d_area_entered(area: Area3D) -> void:
	#
	#if area.is_in_group("Player"):
		#print("you are interacting")
		#player_in_range = true
		##gate3D.player_in_range = true
		#print("checking the gate")
	#if opened == true and area.is_in_group("Player"):
		#TODO: Rewarding sword objects
		#player.has_sword = true


#func _on_chest_area_3d_area_exited(area: Area3D) -> void:
	#if area.is_in_group("Player"):
		#player_in_range = false
		#gate3D.player_in_range = false
		#print("player left")

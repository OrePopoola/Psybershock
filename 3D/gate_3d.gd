extends Node3D
#GATE 3D
@onready var opened_sprite = $"../Opened"
@onready var unopened_sprite =$"../Unopened"
@export var unopened : Sprite3D
@export var opened : Sprite3D
@export var locked_text : Array[String] 
@export var unlocked_text : Array[String] = []# Just change to string to go back to normal
@export var inventoryItem : Node3D 

@onready var dialogueBox = $"../StaticBody3D/3DDialogue"
@onready var Inventory
var player_in_range = false
var unlocked = false
var itemName
func _ready():
	Inventory = Global.Inventory
	dialogueBox.dialogue_text = locked_text
	itemName = inventoryItem.item_name
	inventoryItem = $"../Key"
#first we are going to check whether the player is in range, then
		
#func _process(delta: float) -> void:
	#print(inventoryItem)
	#if player_in_range :
	#	print("Reading from the Chest.. all is good")
	#if player_in_range and !unlocked:
#
		#dialogueBox.dialogue_text = locked_text
		#print(itemName)
		#inventoryItem = $"../Key"
		#print(inventoryItem)
	#if player_in_range and inventoryItem != null:
	##	print("checking inventory initiated")
		#key_check(inventoryItem)
	#if unlocked and player_in_range:
		#unopened_sprite.visible = false
		#opened_sprite.visible = true
		#dialogueBox.dialogue_text = unlocked_text
		##$"../StaticBody3D".collision_layer = 0
		##$"../StaticBody3D".collision_mask = 0
		
func key_check(item): # play when character is in range
	for i in range(Inventory.size()):
		#print("Check One")
		#if Inventory[i] != null:
		#	print(Inventory[i]["name"])
		#	print("Check Two")
		if Inventory[i] != null and Inventory[i]["name"] == itemName:
			print("Unlocked!!!")
			unlocked = true
		#	print("Item stack incremented")

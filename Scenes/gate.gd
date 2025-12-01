extends Node2D
@onready var opened_sprite = $Opened
@onready var unopened_sprite = $Unopened
@export var unopened : Texture
@export var opened : Texture
@export var locked_text : Array[String] = []
@export var unlocked_text : Array[String] = []# Just change to string to go back to normal
@export var inventoryItem : Node2D 

@onready var dialogueBox = $StaticBody2D/Dialogue
@onready var Inventory
var player_in_range = false
var unlocked = false
var itemName
func _ready():
	opened_sprite.texture = opened
	unopened_sprite.texture = unopened
	Inventory = Global.Inventory
	dialogueBox.dialogue_text = locked_text
	itemName = inventoryItem.name
#first we are going to check whether the player is in range, then
		
func _process(delta: float) -> void:
	#print(inventoryItem)
	if player_in_range and !unlocked:
		dialogueBox.dialogue_text = locked_text
	if player_in_range and inventoryItem != null:
		
		key_check(inventoryItem)
	if unlocked and player_in_range:
		unopened_sprite.visible = false
		opened_sprite.visible = true
		dialogueBox.dialogue_text = unlocked_text
		$StaticBody2D.collision_layer = 0
		$StaticBody2D.collision_mask = 0
		
func key_check(item): # play when character is in range
	for i in range(Inventory.size()):
		#print("Check One")
		#if Inventory[i] != null:
		#	print(Inventory[i]["name"])
		#	print("Check Two")
		if Inventory[i] != null and Inventory[i]["name"] == itemName:
			unlocked = true
		#	print("Item stack incremented")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false

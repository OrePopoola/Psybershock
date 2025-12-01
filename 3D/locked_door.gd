extends Node3D

@onready var level_block = $LevelBlock
var player_in_range
var has_key = false
@onready var dialogue = $"3DDialogue"
@export var locked_text : Array[String]
@export var opened_text : Array[String]
@onready var key = $Key
@export var key_item_type : String
@export var key_item_name	:String
@export var key_item_texture :CompressedTexture2D
@export var key_item_effect : String
@export var door_number = 3
@export var north_face = 0
@export var south_face = 0
@export var east_face = 3
@export var west_face = 3
@export var texture_sheet :Texture2D = null
# want to add support for multiple orientations
@export var eastwest = true
@export var northsouth = false
var barriers_up = true
var used_key = false
#my mind is blanking a bit, but I think our goal is to check if the player has a
#key inventoryItem object, based on chest.gd
func _ready() -> void:
	if texture_sheet != null:
		level_block.texture_sheet = texture_sheet
	if eastwest == true:
		level_block.north_face = north_face
		level_block.south_face = south_face
		level_block.east_face = east_face
		level_block.west_face = west_face
	else:
		east_face = 0
		west_face = 0
		#north_face = door_number
		#south_face = door_number
		level_block.north_face = north_face
		level_block.south_face = south_face
		level_block.east_face = east_face
		level_block.west_face = west_face
	dialogue.dialogue_text = locked_text
	key.item_type = key_item_type
	key.item_name = key_item_name
	key.item_texture = key_item_texture
	key.item_effect = key_item_effect
func recheck():
	var found = false
	if has_key == true:	
		for i in range(Global.Inventory.size()):
				if Global.Inventory[i] != null and Global.Inventory[i]["name"] == key_item_name and Global.Inventory[i]["quantity"] > 0 :
					found = true
		if found == false:
			has_key = false
func _physics_process(delta: float):

	
	for i in range(Global.Inventory.size()):
		if Global.Inventory[i] != null and Global.Inventory[i]["name"] == key_item_name and Global.Inventory[i]["quantity"] > 0 : 
			has_key = true

	#print("Has Key:" + str(has_key))
	recheck()
	#print("Rechecking... :" + str(has_key))
	if player_in_range and has_key and eastwest and !used_key and Input.is_action_pressed("Interact"):
		level_block.east_face = -1
		level_block.west_face = -1
		Global.remove_item(key_item_name, key_item_effect)
		has_key = false
		used_key = true
	elif  player_in_range and has_key and northsouth and !used_key and Input.is_action_pressed("Interact"):
		level_block.north_face = -1
		level_block.south_face = -1
		Global.remove_item(key_item_name, key_item_effect)
		has_key = false
		used_key = true
		
	elif key_item_name == "" and player_in_range and Input.is_action_pressed("Interact"):
		print("choice 3")
		if eastwest:
			level_block.east_face = -1
			level_block.west_face = -1
		elif northsouth:
			level_block.north_face = -1
			level_block.south_face = -1
		


	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		print("Has Key:" + str(has_key))
	
		


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false

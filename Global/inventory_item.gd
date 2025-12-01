@tool
extends Node2D
# we are going to need an item description
# we eventually want to have worlds and slideshows that you go into inside of an item
# crafting information will be needed

@export var item_type  = ""
@export var item_name = ""
@export var item_texture: Texture
@export var item_effect = ""
var scene_path: String =  "res://Global/Inventory_Item.tscn"

var player_in_range = false

@onready var icon_sprite = $Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		icon_sprite.texture = item_texture
	#NOTE: might need to change to UI Add
	if player_in_range and Input.is_action_just_pressed("Interact"):
		pickup_item()
		# We need a way to interact with items within a 2d world. Will it use some of this code?
func pickup_item():
	var item = {
		"quantity" : 1,
		"type" : item_type,
		"name" : item_name,
		"texture" : item_texture,
		"effect" : item_effect,
		"scene_path" : scene_path,
	}
	if Global.player_node:
		
		Global.add_item(item)
		self.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group(("Player")):
		print("Activated")
		player_in_range = true
		body.interact_ui.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group(("Player")):
		player_in_range = false
		body.interact_ui.visible = false
func set_item_data(data):
	item_type = data["type"]
	item_name = data["name"]
	item_effect = data["effect"]
	item_texture = data["texture"]
	
func drop_item(item_data, drop_position):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	

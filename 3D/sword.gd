# sword.gd
extends StaticBody3D
var item = {}
@onready var preview = $Sprite3D
@export var item_name : String
@export var item_description : String
@export var item_damage : int
@export var texturePath: String ="res://Assets/3D/weapons/sword_2.png"

func _ready():
	preview.texture = load(texturePath)
	$Sprite3D.billboard = BaseMaterial3D.BILLBOARD_ENABLED # Minecraft-like 2D look
	$Area3D.body_entered.connect(_on_area_3d_body_entered)
	#reward_data = {
	#"name"       : "Crowbar",
	#"type"       : "weapon",
	#"texture"    : "res://Assets/Art/equipment/crowbar.png",
	#"quantity"   : 1,
	#"effect"     : "",               # not used for weapons
	#"scene"      : "",   # <-- 3D model
	#"swing_style": "hammer",          # optional, defaults to "sword"
	#"damage"     : 4
#}
	item = {
	"name"       : item_name,
	"type"       : "weapon",
	"texture"    : texturePath,
	"quantity"   : 1,
	"effect"     : "",               # not used for weapons
	"scene"      : "",   # <-- 3D model
	"swing_style": "sword",          # optional, defaults to "sword"
	"damage"     : item_damage,
	"description" : item_description,
}

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("detected")
	if body.is_in_group("Player"):
		#var player = body
		print("player equip activated")
		Global.add_item(item) 
		#Global.player_node.equip_weapon(item)
		#Global.equipped_weapon = item
		#body.has_sword = true
		#body.sword_sprite.visible = true
		queue_free() # Remove sword from scene

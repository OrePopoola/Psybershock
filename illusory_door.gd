
extends Node3D

var player_in_range
@onready var level_block = $LevelBlock 
@export var eastwest = true
@export var northsouth = false
@export var door_number = 3
@export var north_face = -1
@export var south_face = -1
@export var east_face = -1
@export var west_face = -1
@export var top_face = 21
@export var bottom_face = 21
@export var texture_sheet :Texture2D = null

func _ready() -> void:
	if texture_sheet != null:
		level_block.texture_sheet = texture_sheet
	if eastwest == true:
		level_block.north_face = north_face
		level_block.south_face = south_face
		level_block.east_face = east_face
		level_block.west_face = west_face
		level_block.top_face = top_face
		level_block.bottom_face = bottom_face
	else:
		east_face = 0
		west_face = 0
		#north_face = door_number
		#south_face = door_number
		level_block.north_face = north_face
		level_block.south_face = south_face
		level_block.east_face = east_face
		level_block.west_face = west_face
		
func _physics_process(delta: float):
	if player_in_range and Input.is_action_pressed("Interact") and eastwest:
		level_block.east_face = -1
		level_block.west_face = -1
	elif player_in_range and Input.is_action_pressed("Interact") and northsouth:
		level_block.north_face = -1
		level_block.south_face = -1
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		print("Illusory Door")


func _on_area_3d_body_exited(body: Node3D) -> void:
	pass # Replace with function body.

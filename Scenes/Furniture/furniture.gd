extends Sprite2D



@onready var talkCollision = $Area2D
@export var dialogueLines : Array[String] = []
var player_in_range = false
var current_player: Node2D = null
var in_dialogue = false
var index = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		print("Detected Player")
		player_in_range = true
		current_player = body
		#_insert_dialogue(body)
func _on_area_2d_body_exited(body: Node2D) -> void:

	if(body.is_in_group("Player")):
		print("triggering")
		current_player.dialogue_ui.visible = false
		player_in_range = false
		
func _process(delta: float) -> void:
	if player_in_range and !in_dialogue and  Input.is_action_just_pressed("Talk"):
		current_player.dialogue_ui.visible = true
		in_dialogue = true
		print("inserting dialogue")
		_insert_dialogue(current_player)
	if(in_dialogue): #should this be here?
		_insert_dialogue(current_player)

func _insert_dialogue(body):
	print("Entered function")
	in_dialogue = false
	
	if(index < len(dialogueLines) and player_in_range ):
		body.dialogue_text.text = dialogueLines[index]
		index += 1
	if(index >= len(dialogueLines)):
		index = 0
	if !player_in_range:
		print("cleanup triggered")
		current_player.dialogue_ui.visible = false
	#body.dialogue_text.text = "Ciao"
	

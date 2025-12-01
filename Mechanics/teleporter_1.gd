extends Area2D
@onready var destination = $"../Teleporter2"
@onready var source = $"."
var player = null
var player_in_range1 = false
var player_in_range2 = false

func _on_body_entered(body: Node2D) -> void: #Teleporter 1
	if body.is_in_group("Player"):
		player = body
		player_in_range1 = true
		print("Entered Teleporter 1")


func _on_body_exited(body: Node2D) -> void:
	player_in_range1 = false

	
func _on_teleporter_2_body_exited(body: Node2D) -> void:
	player_in_range2 = false


func _on_teleporter_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_in_range2 = true
		print("Entered Teleporter 2")
func _physics_process(delta: float) -> void:
	if player_in_range1 and Input.is_action_just_pressed("Interact"):
		player.global_position = destination.global_position
		
	elif player_in_range2 and Input.is_action_just_pressed("Interact"):
		player.global_position = source.global_position

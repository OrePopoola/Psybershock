extends AnimatedSprite2D
@onready var animated_sprite = $"."
@onready var player_in_range = false
#add a player_in_range and area2D to this
func _input(event):
	if animated_sprite.is_playing() and player_in_range:
		if event.is_action_pressed("Interact"):
			animated_sprite.stop()
	elif event.is_action_pressed("Interact") and player_in_range:
		animated_sprite.play("default")
	
	
		
	


func _on_player_detector_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		player_in_range = true


func _on_player_detector_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		player_in_range = false

extends Node3D

#should switch to conversational combat
func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body.is_in_group("Player"):
		var error = get_tree().change_scene_to_file("res://Scenes/ConversationalCombat/conversational_combat.tscn")
		if error != OK:
			print("Error loading 2D scene: ", error)

extends Node2D

@onready var Ladder
@onready var player = $"res://Player/player.tscn"
var changed = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body
	if body.is_in_group("Player") and player and player.grav_on == true:
		player.grav_on = false
		changed= true
		player.ladder = true
		print("activated v1")



func _on_area_2d_body_exited(body: Node2D) -> void:
	if changed == true:
		player.grav_on = true
		player.ladder = false
		print("deactivated v1")

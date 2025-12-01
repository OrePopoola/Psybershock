
extends Node2D

#@export var dungeon_scene: PackedScene  # Drag Dungeon.tscn here

signal combat_ended(won: bool)  # Optional: Pass win state back

func end_combat(won: bool = true) -> void:
	combat_ended.emit(won)
	#get_tree().change_scene_to_packed(dungeon_scene)

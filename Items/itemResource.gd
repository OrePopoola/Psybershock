extends Resource
class_name itemInventory

@export var item_texture: Texture2D
@export var item_name: String
@export var item_type: String
@export var item_effect: String
@export var scene_path: String
@export var tags: Array[String] = []   # e.g. ["rage","memory"]
@export var description :String

var item = {
		"quantity" : 1,
		"type" : item_type,
		"name" : item_name,
		"texture" : item_texture,
		"effect" : item_effect,
		"scene_path" : scene_path,
		"description" : description,
		"tags" : tags,
	}

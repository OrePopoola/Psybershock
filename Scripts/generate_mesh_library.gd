@tool
extends EditorScript

func _run():
	var texture_path = "res://addons/level_block/example2.png"
	if not ResourceLoader.exists(texture_path):
		print("Error: Texture not found at ", texture_path)
		return
	var texture = load(texture_path)
	if not texture:
		print("Error: Failed to load texture at ", texture_path)
		return

	var mesh_library = MeshLibrary.new()

	var level_block = load("res://addons/level_block/level_block_node.gd").new()
	level_block.texture_sheet = load("res://addons/level_block/example2.png")
	print("variants2")
	level_block.texture_size = 32

	
	# Define block variants (e.g., floor, wall, corner)
	
	var variants = [
		{"name": "floor", "top_face": 0, "others": -1},
		{"name": "wall_north", "north_face": 1, "others": -1},
		{"name": "wall_north_south", "north_face": 1, "south_face": 1, "others": -1},
		# Add more variants as needed
	]

	for i in variants.size():
		var variant = variants[i]
		level_block.north_face = variant.get("north_face", variant.others)
		level_block.east_face = variant.get("east_face", variant.others)
		level_block.south_face = variant.get("south_face", variant.others)
		level_block.west_face = variant.get("west_face", variant.others)
		level_block.top_face = variant.get("top_face", variant.others)
		level_block.bottom_face = variant.get("bottom_face", variant.others)
		level_block.refresh()
		mesh_library.create_item(i)
		
		mesh_library.set_item_mesh(i, level_block.create_mesh())
		mesh_library.set_item_name(i, variant.name)
	
	ResourceSaver.save(mesh_library, "res://Meshes//level_block_library.tres")

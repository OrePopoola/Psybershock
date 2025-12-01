extends CanvasLayer

var damage_number_scene = preload("res://UI/damage_number.tscn")  # Adjust path


func spawn_damage(world_pos: Vector3, amount: int, is_crit: bool = false, dmg_color: Color = Color(1, 0.8, 0.8)):
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return

	var screen_pos: Vector2 = camera.unproject_position(world_pos)

	# Skip if way off/back-screen (grow() adds margin)
	var viewport_rect = get_viewport().get_visible_rect()
	if not viewport_rect.grow(200).has_point(screen_pos):
		return

	var dmg_num = damage_number_scene.instantiate()
	dmg_num.position = screen_pos + Vector2(randf_range(-15,15), -30)  # Jitter + offset
	dmg_num.damage_amount = amount
	dmg_num.crit = is_crit
	dmg_num.color = dmg_color
	add_child(dmg_num)

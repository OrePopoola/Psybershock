extends Node3D

@onready var front_ray = $FrontRay      # RayCast3D for -Z
@onready var back_ray  = $BackRay       # RayCast3D for +Z
@onready var left_ray  = $LeftRay       # RayCast3D for -X
@onready var right_ray = $RightRay      # RayCast3D for +X
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var detection_area = $Area3D
@onready var goblin = $Goblin           # Inherited scene with MeshInstance3D + AnimationPlayer
@onready var animation_player = $Goblin/AnimationPlayer
@onready var goblin_mesh = $Goblin/MeshInstance3D
@export var health: int = 6
@export var damage: int = 1
var tween: Tween = null
var last_attack_time: float = -8.0
var is_attacking: bool = false
var is_moving: bool = false
var last_direction_change_time: float = 0.0

@export var grid_size: float = 2
@export var move_speed: float = 3
@export var detection_range: float = 2
@export var gravity: float = 9.8
@export var attack_cooldown: float = 3
@export var stab_animation_name: String = "stabbing"
@export var walk_animation_name: String = "walking"
@export var direction_change_cooldown: float = 0.5

func _ready() -> void:
	add_to_group("Enemy")
	if detection_area.has_node("CollisionShape3D"):
		detection_area.get_node("CollisionShape3D").shape.radius = detection_range

	# Snap to grid
	global_position.x = round(global_position.x / grid_size) * grid_size
	global_position.z = round(global_position.z / grid_size) * grid_size

	if goblin:
		goblin.visible = true
	if animation_player:
		animation_player.speed_scale = 1.3
		if animation_player.has_animation(walk_animation_name):
			var anim = animation_player.get_animation(walk_animation_name)
			anim.loop_mode = Animation.LOOP_LINEAR

func _physics_process(delta: float) -> void:
	if not player:
		print("Player not found!")
		return

	# ---- CONTINUOUS REALIGNMENT TO PLAYER ----
	if goblin and player:
		var player_pos = player.global_position
		var goblin_pos = goblin.global_position
		var direction_delta = player_pos - goblin_pos  # Renamed to avoids conflict
		# Calculate base rotation toward player with offset
		var base_rotation = atan2(direction_delta.x, direction_delta.z)
		var rotation_offset = deg_to_rad(90)  # Adjust this value (e.g., 90, -90, 180, 0) based on model
		goblin.rotation.y = base_rotation + rotation_offset

	update_animation()

	# movement tween state
	if tween and tween.is_running():
		is_moving = true
	else:
		is_moving = false

	var player_pos = player.global_position
	var enemy_pos = self.global_position
	var distance = abs(player_pos.x - enemy_pos.x) + abs(player_pos.z - enemy_pos.z)

	# ---- ATTACK ----
	if distance <= grid_size + 0.05:          # adjacent cell
		attack_player()
		return

	# ---- NAVIGATION ----
	var direction = Vector3.ZERO
	var delta_x = player_pos.x - enemy_pos.x
	var delta_z = player_pos.z - enemy_pos.z
	var current_time = Time.get_ticks_msec() / 1000.0

	if abs(delta_x) > 0.1 or abs(delta_z) > 0.1:
		var possible = []
		if delta_x > 0 and not right_ray.is_colliding():
			possible.append(Vector3(grid_size, 0, 0))
		elif delta_x < 0 and not left_ray.is_colliding():
			possible.append(Vector3(-grid_size, 0, 0))
		if delta_z > 0 and not back_ray.is_colliding():
			possible.append(Vector3(0, 0, grid_size))
		elif delta_z < 0 and not front_ray.is_colliding():
			possible.append(Vector3(0, 0, -grid_size))

		if possible.size() > 0:
			if current_time - last_direction_change_time >= direction_change_cooldown or tween == null:
				direction = possible[0]
				last_direction_change_time = current_time
				print("Chosen direction: ", direction)

	if direction != Vector3.ZERO:
		# Movement rotation is overridden by continuous realignment above
		if not tween or not tween.is_running():
			tween = create_tween()
			var target = enemy_pos + direction
			target.x = round(target.x / grid_size) * grid_size
			target.z = round(target.z / grid_size) * grid_size
			tween.tween_property(self, "global_position", target, move_speed)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_callback(func(): is_moving = false)

	else:
		#print("No valid move direction")
		pass

func update_animation() -> void:
	if is_attacking and animation_player and animation_player.has_animation(stab_animation_name):
		if animation_player.current_animation != stab_animation_name:
			animation_player.play(stab_animation_name)
	elif is_moving and animation_player and animation_player.has_animation(walk_animation_name):
		if animation_player.current_animation != walk_animation_name:
			animation_player.play(walk_animation_name)
	else:
		if animation_player and animation_player.current_animation != "":
			animation_player.stop()

func attack_player() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time < attack_cooldown or is_attacking:
		return

	print("Attack Formation! Playing stab animation!")
	is_attacking = true

	# ---- PLAY STAB (using current player-facing rotation) ----
	if animation_player and animation_player.has_animation(stab_animation_name):
		animation_player.play(stab_animation_name)
		if not animation_player.animation_finished.is_connected(_on_stab_finished):
			animation_player.animation_finished.connect(_on_stab_finished)

	# ---- DAMAGE ----
	if player:
		player.take_damage(damage)

	last_attack_time = current_time

func _on_stab_finished(anim_name: String) -> void:
	if anim_name == stab_animation_name:
		is_attacking = false
		print("Stab animation finished!")

# ----------------------------------------------------------------------
#  DAMAGE / KNOCK-BACK (unchanged)
# ----------------------------------------------------------------------
func take_damage(amount: int) -> void:
	print("took damage: ", amount)
	health -= amount
	print("Enemy Health: " + str(health))
	if health <= 0:
		print("Enemy defeated!")
		queue_free()
		return

	if player:
		var player_pos = player.global_position
		var enemy_pos = self.global_position
		var direction = Vector3.ZERO
		var delta = enemy_pos - player_pos
		if abs(delta.x) > abs(delta.z):
			if delta.x > 0 and not right_ray.is_colliding():
				direction = Vector3(grid_size, 0, 0)
			elif delta.x < 0 and not left_ray.is_colliding():
				direction = Vector3(-grid_size, 0, 0)
		else:
			if delta.z > 0 and not back_ray.is_colliding():
				direction = Vector3(0, 0, grid_size)
			elif delta.z < 0 and not front_ray.is_colliding():
				direction = Vector3(0, 0, -grid_size)

		if direction != Vector3.ZERO:
			if tween and tween.is_running():
				tween.kill()
			tween = create_tween()
			var target = enemy_pos + direction
			target.x = round(target.x / grid_size) * grid_size
			target.z = round(target.z / grid_size) * grid_size
			tween.tween_property(self, "global_position", target, 0.4)
			tween.set_ease(Tween.EASE_IN_OUT)

		if animation_player and animation_player.has_animation("hurt"):
			animation_player.play("hurt")

func _on_area_3d_2_area_entered(area: Area3D) -> void:
	if area.is_in_group("Weapon_Player") and player.is_attacking:
		print("WE GOT EM")
		take_damage(Global.equipped_weapon.damage)
		
		if goblin_mesh:
			var mat = goblin_mesh.get_surface_override_material(0)
			if mat:
				mat.albedo_color = Color.RED
				var t = create_tween()
				t.tween_delay(0.1)
				t.tween_callback(func(): mat.albedo_color = Color.WHITE)

func _on_area_3d_2_area_exited(area: Area3D) -> void:
	if area.is_in_group("Weapon_Player"):
		pass

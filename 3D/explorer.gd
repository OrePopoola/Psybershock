extends Node3D
const TRAVEL_TIME := 0.3

@onready var right_ray := $RightRay
@onready var left_ray := $LeftRay
@onready var front_ray := $FrontRay
@onready var back_ray := $BackRay
@onready var dialogue_ui = $DialogueUI
@onready var dialogue_text = $DialogueUI/ColorRect/Label
@onready var inventory_hotbar = $InventoryHotbar
var tween
var move_speed = 2.0 # Time in seconds for tween
var has_sword = false

### Experimental  Grok Code
@onready var weapon_pivot : Node3D = $WeaponPivot      # <-- NEW empty Node3D under the player
@onready var weapon_area   : Area3D = $WeaponPivot/Area3D
###
var damage

signal health_changed(new_health: float)
var is_attacking = false
#@onready var sword_sprite = $SwordPivot/Sprite3D
var grid_size = 1.0
@onready var pickup_area = $SwordPivot/Area3D
@onready var sword_pivot: Node3D = $SwordPivot
@onready var inventory_ui = $InventoryUI
@onready var interact_ui = $InteractUI

var max_health = 99
var health = 99

# ------------------------------------------------------------------
# Public API – called from InventorySlot when the Equip button is pressed
# ------------------------------------------------------------------
func equip_weapon(item_data: Dictionary) -> void:
	print("Equipped: ", item_data.get("name", "?"))
	# 1. Unequip current weapon (if any)
	if Global.equipped_weapon_node:
		Global.equipped_weapon_node.queue_free()
		Global.equipped_weapon_node = null
		Global.equipped_weapon = {}

	# 2. Store reference
	Global.equipped_weapon = item_data.duplicate()   # keep a copy
	print("Equipped weapon" + str(Global.equipped_weapon))
	if item_data["swing_style"] == "sword":
			weapon_pivot.position.x = -0.446
			weapon_pivot.position.y = 0.29 # controls height of swing
			weapon_pivot.position.z = 0
			
	# 3. -----------------------------------------------------------------
	#    CREATE THE VISUAL NODE (Scene  OR  Sprite3D)
	# TODO: ADD THIS SECTIO BACK LATER
	# -----------------------------------------------------------------
	#if item_data.has("scene") and ResourceLoader.exists(item_data.scene):
	#	# ---- 3-D model -------------------------------------------------
#		var weapon_scene: PackedScene = load(item_data.scene)
	#	Global.equipped_weapon_node = weapon_scene.instantiate()
	#	weapon_pivot.add_child(Global.equipped_weapon_node)
	var loaded_texture = ResourceLoader.load(item_data.texture) as Texture
	item_data["texture"] = loaded_texture
	if item_data.has("texture") and item_data.texture is Texture:
		print("equipment texture reeady")
		# ---- Sprite3D (2-D icon) ---------------------------------------
		Global.equipped_weapon_node = _create_sprite3d_from_texture(item_data.texture)
		
	
		if item_data["swing_style"] == "sword":
			weapon_pivot.position.x = -0.446
			weapon_pivot.position.y = 0.29 # controls height of swing
			weapon_pivot.position.z = 0 #0.125
		
		#_apply_weapon_positioning(item_data)
		weapon_pivot.add_child(Global.equipped_weapon_node)
		if item_data["swing_style"] == "sword":
			Global.equipped_weapon_node.position.x = 1.232
			Global.equipped_weapon_node.position.y = 0.165
			Global.equipped_weapon_node.position.z = -0.764
			Global.equipped_weapon_node.scale.x = 1
			Global.equipped_weapon_node.scale.y = 1
			Global.equipped_weapon_node.scale.z = 1
	
		#print("Sword position" + str(Global.equipped_weapon_node.position))
		
	else:
		push_warning("Weapon %s has neither a valid 'scene' nor a 'texture'!" % item_data.get("name", "?"))
		weapon_pivot.visible = false
		Global.equipment_changed.emit()
		return
	# 4. Make it visible
	weapon_pivot.visible = true
	Global.equipment_changed.emit()


func _apply_weapon_positioning(item_data: Dictionary) -> void:
	# WeaponPivot position
	var pivot_pos = item_data.get("pivot_pos", {"x":0, "y":0, "z":0})
	weapon_pivot.position = Vector3(
		pivot_pos.get("x", 0),
		pivot_pos.get("y", 0), 
		pivot_pos.get("z", 0))
	
	# Weapon sprite position (relative to pivot)
	var weapon_pos = item_data.get("weapon_pos", {"x":0, "y":0, "z":0})
	Global.equipped_weapon_node.position = Vector3(
		weapon_pos.get("x", 0),
		weapon_pos.get("y", 0),
		weapon_pos.get("z", 0)
	)
	
	# Weapon sprite scale
	var weapon_scale = item_data.get("weapon_scale", {"x":1, "y":1, "z":1})
	Global.equipped_weapon_node.scale = Vector3(
		weapon_scale.get("x", 1),
		weapon_scale.get("y", 1),
		weapon_scale.get("z", 1)
	)

func unequip_weapon() -> void:
	if Global.equipped_weapon_node:
		Global.equipped_weapon_node.queue_free()
		Global.equipped_weapon_node = null
		Global.equipped_weapon = {}
	weapon_pivot.visible = false
	Global.equipment_changed.emit()
# ------------------------------------------------------------------
# Helper – builds a Sprite3D with sensible defaults
# ------------------------------------------------------------------
func _create_sprite3d_from_texture(tex: Texture) -> Sprite3D:
	var spr = Sprite3D.new()
	spr.texture = tex
	#spr.pixel_size = 0.01
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	 # tweak to match your world scale
	#spr.billboard = BaseMaterial3D.BILLBOARD_ENABLED   # always face camera
	spr.shaded = false
	spr.transparent = true
	spr.modulate = Color.WHITE
	# Optional: center the sprite on the pivot
	spr.offset = Vector2(36, -36)# makes sure the png is in the right place starting out
	
	return spr
#func swing_sword():
	#print("started swinging sword")
	#is_attacking = true
	#sword_pivot.visible = true
	#sword_sprite.visible = true
#
	## Create a tween for the sword swing animation
	#var sword_tween = create_tween()
	#sword_tween.tween_property(sword_pivot, "rotation_degrees:x", -60, 0.2)
	#sword_tween.tween_property(sword_pivot, "rotation_degrees:y", 90, 0.2)
	## Enable attack collision at the peak of the swing
	#sword_tween.tween_callback(func():
		#var attack_area = sword_pivot.get_node("Area3D")
		#attack_area.monitoring = true
		#for body in attack_area.get_overlapping_bodies():
			#if body.is_in_group("Enemy"):
				#body.take_damage(1)
				#print("hitting enemy")
		#attack_area.monitoring = false
	#)
	#sword_tween.tween_property(sword_pivot, "rotation_degrees:y", 0, 0.2)
	#sword_tween.tween_property(sword_pivot, "rotation_degrees:x", -31.8, 0.2)
	#sword_tween.tween_callback(_on_sword_swing_finished)
	#print("finishing swing")

func _on_sword_swing_finished():
	is_attacking = false

func _physics_process(delta: float) -> void:
	#if has_sword:
	#	sword_pivot.visible = true
	#	sword_sprite.visible = true

	if tween is Tween:
		if tween.is_running():
			return
	if Input.is_action_pressed("Move Up") and not front_ray.is_colliding():
		tween = create_tween()
		tween.tween_property(self, "transform", transform.translated(transform.basis.z * -2), TRAVEL_TIME)
	if Input.is_action_pressed("Move Down") and not back_ray.is_colliding():
		tween = create_tween()
		tween.tween_property(self, "transform", transform.translated(transform.basis.z * 2), TRAVEL_TIME)
	if Input.is_action_pressed("Move Left"):
		tween = create_tween()
		tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, PI/2), TRAVEL_TIME)
	if Input.is_action_pressed("Move Right"):
		tween = create_tween()
		tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, -PI/2), TRAVEL_TIME)
	if Input.is_action_pressed("Strafe Right") and not right_ray.is_colliding():
		tween = create_tween()
		tween.tween_property(self, "transform", transform.translated(transform.basis.x * 2), TRAVEL_TIME)
	if Input.is_action_pressed("Strafe Left") and not left_ray.is_colliding():
		tween = create_tween()
		tween.tween_property(self, "transform", transform.translated(transform.basis.x * -2), TRAVEL_TIME)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Attack") and Global.equipped_weapon and not is_attacking:
		print("starting weapon swing")
		Global.equipped_weapon_node.offset = Vector2(0,0)
		_start_weapon_swing(Global.equipped_weapon)
	#if event.is_action_pressed("Attack") and has_sword and not is_attacking:
		#swing_sword()
		#print("sword swung")
		
	if event.is_action_pressed("Inventory"):
		inventory_ui.visible = !inventory_ui.visible
		inventory_hotbar.visible = !inventory_hotbar.visible
		
func _start_weapon_swing(item: Dictionary) -> void:
	
	#sword_pivot.visible = true
	#sword_sprite.visible = true
	is_attacking = true
	weapon_area.monitoring = false          # safety

	# ---- 1. Choose swing style (default = sword) -----------------
	var swing_style : String = item.get("swing_style", "sword")

	# ---- 2. Load the swing data (you can store it in a dict) -----
	var swing = _get_swing_data(swing_style)
	#print(swing)
	# ---- 3. Build the tween ----------------------------------------
	var tween = create_tween()
	tween.set_parallel(false)

	# start pose
	tween.tween_property(weapon_pivot, "rotation_degrees", swing.start_rot, swing.windup_time)

	# enable collision at the peak
	tween.tween_callback(func():
		weapon_area.monitoring = true
		for body in weapon_area.get_overlapping_bodies():
			if body.is_in_group("Enemy"):
				body.take_damage(item.get("damage", 1))
				DamageManager.spawn_damage(body.global_position + Vector3.UP * 1.5, 1337, true)
		weapon_area.monitoring = false)

	# finish pose
	tween.tween_property(weapon_pivot, "rotation_degrees", swing.end_rot, swing.recovery_time)
	tween.tween_callback(func():
		is_attacking = false)

func take_damage(amount):
	health -= amount
	print("Player Health: ", health)
	health_changed.emit(health)
	if health <= 0:
		# Game over logic
		queue_free()

func apply_item_effect(item):
	match item["effect"]:
		"Healing":
			health += 50
		_:
			print("no effect for this item")

# ------------------------------------------------------------------
# Swing-style database – add as many as you want
# ------------------------------------------------------------------
func _get_swing_data(style: String) -> Dictionary:
	match style:
		"sword":
			return {
				start_rot   = Vector3(-60, 90, 0),
				end_rot     = Vector3(-31.8, 0, 0),
				windup_time = 0.2,
				recovery_time = 0.2,
				pivot_pos = {"x": -0.446, "y": 0.29, "z": 0},      # WeaponPivot position
				weapon_pos = {"x": 1.232, "y": 0.165, "z": -0.764}, # Weapon sprite position
   				weapon_scale = {"x": 1.0, "y": 1.0, "z": 1.0} ,
				}
		"axe":
			return {
				start_rot   = Vector3(-90, 0, 0),
				end_rot     = Vector3(-20, 0, 0),
				windup_time = 0.3,
				recovery_time = 0.25
			}
		"hammer":
				return {
				start_rot   = Vector3(-120, 0, 0),
				end_rot     = Vector3(-10, 0, 0),
				windup_time = 0.4,
				recovery_time = 0.35
}
		_:
			return {
				start_rot   = Vector3(-60, 90, 0),
				end_rot     = Vector3(-31.8, 0, 0),
				windup_time = 0.2,
				recovery_time = 0.2
			}

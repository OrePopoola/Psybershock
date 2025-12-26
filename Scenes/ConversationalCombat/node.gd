extends Node

enum State { PLAYER_TURN, ENEMY_TURN }
var current_state: State = State.PLAYER_TURN
var player_ego: int = 100  # Your "health"
var enemy_ego: int = 100   # Killer's ego to break
@onready var screwdriver = $"Bloody screwdriver"
@onready var photo_friends = $"Photo of Friends"
@onready var case_log = $"Case Log"
@onready var combat_root = get_parent()  # MindCombat node
@onready var craft_button = $"Craft Button"
@onready var attack_button =$"Attack Button"
@onready var enemy_portrait = $"../UI/enemyPortrait"
@onready var player_health = $"../UI/playerPortrait/Label"
@onready var enemy_health = $"../UI/enemyPortrait/Label"
@onready var player_portrait = $"../UI/playerPortrait"

func _ready() -> void:
	#print("Screwdriver :" + str(screwdriver))
	Global.reset_inventory()
	Global.artifact_1 = true
	Global.artifact_2 = true
	Global.artifact_3 = true
	

	if Global.artifact_1:
		photo_friends.pickup_item()
	if Global.artifact_2:
		screwdriver.pickup_item()
	if Global.artifact_3:
		case_log.pickup_item()
	
	#artifact_purge()
	
	next_turn()
	
#
func next_turn() -> void:
	match current_state:
		State.PLAYER_TURN:
			# Show crafting UI, wait for player input
			print("Craft your move...")
			
			# Connect to UI signal for crafted move
		State.ENEMY_TURN:
			# Pull random lie from speech log, "attack"
			#var lie = get_random_lie()  # From speech log
			#apply_damage(lie, true)  # Enemy attacks
			#TODO: detect inaccuracies in player attack and punish player
			print("Enemy Turn")
			if player_ego > 0:
				player_ego -= 33
				current_state = State.PLAYER_TURN
				#add time delay
				next_turn()
			else:
				##Load in Unconscious
				queue_free()
				#current_state = State.RESOLVE
		#State.RESOLVE:
			## Apply move effects, check win/lose
			#current_state = State.PLAYER_TURN
			#if enemy_ego <= 0:
				#combat_root.end_combat(true)
			#elif player_ego <= 0:
				#combat_root.end_combat(false)
				#print("combat finished")
	current_state = State.values()[ (current_state + 1) % State.size() ]

func apply_damage(move_text: String, is_enemy: bool) -> void:
	# Simple: Damage based on word length or keywords (e.g., "lie" detects)
	var damage = move_text.length() / 10.0  # Placeholder logic
	if is_enemy:
		player_ego -= int(damage)
	else:
		enemy_ego -= int(damage)
	print("Ego hit! Damage: ", damage)
	# Animate UI bar, etc.

func get_random_lie() -> String:
	# Integrate with speech log (see below)
	return "You think you're safe? Lies."  # Placeholder
func artifact_purge():
	if Global.Inventory.size() > 2:	
		for i in range(Global.Inventory.size()):
			if Global.Inventory[i] and Global.Inventory[i]["type"] != "Artifact":
				Global.remove_item(Global.Inventory[i]["name"],Global.Inventory[i]["type"])
			
func artifact_census()-> int:
	var artifacts = 0
	for i in range(Global.Inventory.size()):
		if Global.Inventory[i] != null and Global.Inventory[i]["type"] == "Artifact":
			artifacts += 1
	return artifacts
func clear_hotbar():
	for i in range(Global.hotbar_inventory.size()):
		if Global.hotbar_inventory[i] != null:
			Global.hotbar_inventory[i] = null
			Global.inventory_updated.emit()
	#return true
func hotbar_census()-> int:
	var census = 0
	for i in range(Global.hotbar_inventory.size()):
		if Global.hotbar_inventory[i] != null:
			census += 1
	return census
#IMPORTANT TODO Check against crafting recipe ( maybe in tags) 
# CLEAR THE HOTBAR
#Attack Button Instantiated( or make visible, and craft invisible,
# ATTACK Damages the enemy, and then craft is visible, and attack invisible
# ONLY AFTER THIS CHECK GROK,
# TODO: CHECK CRAFTING RECIPES( maybe by id)
func _on_craft_button_button_down() -> void:
	if hotbar_census() > 1: ## CHANGE to ONE when not testing,
		craft_button.visible = false
		attack_button.visible = true
		for i in range(len(Global.hotbar_inventory)):
			for j in range(len(Global.Inventory)):
				if  Global.Inventory[j] != null and Global.hotbar_inventory[i] != null:
					if Global.Inventory[j]["name"] == Global.hotbar_inventory[i]["name"]:
						Global.remove_item(Global.Inventory[j]["name"], Global.Inventory[j]["effect"])
				
		clear_hotbar()
		
func _process(delta: float) -> void:
	player_health.text = "Health: " + str(player_ego) + "/100"
	enemy_health.text = "Health: " + str(enemy_ego) + "/100"
	if player_ego < 0:
		queue_free()
	if enemy_ego < 0:
		enemy_ego = 999
		print(" You have failed, you lack the neccesary evidence to defeat me!")
		player_ego = 1
#
func _on_attack_button_button_down() -> void:
		enemy_ego -= 30
		craft_button.visible = true
		attack_button.visible = false
		
		print("State: "+ str(current_state))
		next_turn()
		print("State: "+ str(current_state))
		

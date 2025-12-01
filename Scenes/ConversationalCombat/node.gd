extends Node

enum State { PLAYER_TURN, ENEMY_TURN, RESOLVE }
var current_state: State = State.PLAYER_TURN
var player_ego: int = 100  # Your "health"
var enemy_ego: int = 100   # Killer's ego to break
@onready var screwdriver = $"Bloody screwdriver"
@onready var combat_root = get_parent()  # MindCombat node
@onready var craft_button = $"Craft Button"
@onready var attack_button =$"Attack Button"
@onready var enemy_portrait = $"../UI/enemyPortrait"
@onready var player_health = $"../UI/playerPortrait/Label"
@onready var enemy_health = $"../UI/enemyPortrait/Label"
@onready var player_portrait = $"../UI/playerPortrait"

func _ready() -> void:
	print("Screwdriver :" + str(screwdriver))
	screwdriver.pickup_item()
	
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
			var lie = get_random_lie()  # From speech log
			apply_damage(lie, true)  # Enemy attacks
		State.RESOLVE:
			# Apply move effects, check win/lose
			if enemy_ego <= 0:
				combat_root.end_combat(true)
			elif player_ego <= 0:
				combat_root.end_combat(false)
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
		clear_hotbar()
		
func _process(delta: float) -> void:
	player_health.text = "Health: " + str(player_ego) + "/100"
	enemy_health.text = "Health: " + str(enemy_ego) + "/100"
#
func _on_attack_button_button_down() -> void:
		enemy_ego -= 30
		craft_button.visible = true
		attack_button.visible = false
		

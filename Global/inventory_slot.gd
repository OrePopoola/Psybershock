extends Control

@onready var icon = $"Inner Border/Item Icon"
@onready var quantity_label = $"Inner Border/Item Quantity"
@onready var details_panel = $"Details Panel"
@onready var item_name = $"Details Panel/ItemName"
@onready var item_type = $"Details Panel/ItemType"
@onready var item_effect = $"Details Panel/Item Effect"
@onready var usage_panel = $"Usage Panel"

@onready var assignButton = $"Usage Panel/AssignButton"
# Called when the node enters the scene tree for the first time.
@onready var outer_border = $"Outer Border"
@onready var equip_button = $"Usage Panel/EquipButton"
@onready var descriptionButton = $"Usage Panel/DescriptionButton"
var description = null
@onready var dialogue = $"3DDialogue"

signal drag_start(slot)

signal drag_end()


var item = null
var slot_index = -1
var is_assigned = false

func set_slot_index(new_index):
	slot_index = new_index

func _ready() -> void:
	usage_panel.visible = false
	details_panel.visible = false
	# connect the new button
	equip_button.pressed.connect(_on_equip_button_pressed)
	
func update_assignment_status() -> void:
	is_assigned = Global.is_item_assigned_to_hotbar(item)

	# ---- 1. Hotbar assign text (unchanged) -------------------------
	if is_assigned:
		assignButton.text = "Unassign"
	else:
		assignButton.text = "Assign"

	# ---- 2. Equip button (new) ------------------------------------
	if item and item.get("type", "") == "weapon":
		equip_button.visible = true
		if Global.equipped_weapon and Global.equipped_weapon.get("name", "") == item["name"]:
			equip_button.text = "Unequip"
		else:
			equip_button.text = "Equip"
	else:
		equip_button.visible = false
# ------------------------------------------------------------------
# Button callback
# ------------------------------------------------------------------
func _on_equip_button_pressed() -> void:
	if not item or item.get("type", "") != "weapon":
		return

	if equip_button.text == "Unequip":
		Global.player_node.unequip_weapon()
	else:
		Global.player_node.equip_weapon(item.duplicate())   # duplicate so hotbar copy stays intact

	# refresh UI
	update_assignment_status()
	usage_panel.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _on_item_button_pressed() -> void:
	#if item != null:
		#usage_panel.visible = !usage_panel.visible


func _on_item_button_mouse_entered() -> void:
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true


func _on_item_button_mouse_exited() -> void:
	details_panel.visible = false
	
func set_empty():
	icon.texture = null
	quantity_label.text = ""
func set_item(new_item):
	item = new_item
	description = item["description"] # FEED THIS INTO DIALOGUE
	print("Description:" + str(description))
	if new_item["texture"] is not Texture:
		icon.texture = load(new_item["texture"])
		
	else:
		icon.texture = new_item["texture"]
	
	quantity_label.text = str(item["quantity"])
	item_name.text = str(item["name"])
	
	item_type.text =  str(item["type"])
	if item["effect"] != "":
		item_effect.text = str("*", item["effect"])
	else:
		item_effect.text = ""
	update_assignment_status()


#func _on_drop_button_pressed() -> void:
	#if item != null:
		#var drop_position = Global.player_node.global_position
		## EDIT: CHANGE THIS TO CHANGE DROP POSITION (DROP_BUTTON_PRESSED OFFSET)
		#var drop_offset = Vector2(0,0)
		#drop_offset = drop_offset.rotated(Global.player_node.rotation)
		#Global.drop_item(item, drop_position + drop_offset)
		#Global.remove_item(item["type"], item["effect"])
		#Global.remove_hotbar_item(item["type"], item["effect"])
		#usage_panel.visible = false
		
func _on_use_button_pressed():
	usage_panel.visible = false
	if item != null and item["effect"] != "":
		if Global.player_node:
			Global.player_node.apply_item_effect(item)
			Global.remove_item(item["type"], item["effect"])
			Global.remove_hotbar_item(item["type"], item["effect"])
		else:
			print("could not be found")
			
			
# Uncommment if grok code breaks
#func update_assignment_status():
	#is_assigned = Global.is_item_assigned_to_hotbar(item)
	#if is_assigned:
		#assignButton.text = "Unassign"
	#else:
		#assignButton.text = "Assign"


func _on_assign_button_pressed() -> void:
	if assignButton.text == "Unassign": # tutorial says item != null
		print(" removing assignment")
		if is_assigned:
			Global.unassign_hotbar_item(item["type"], item["effect"])
			is_assigned = false
	else:
		print("assigning item")
		Global.add_item(item, true)
		is_assigned = true
	update_assignment_status()
	


func _on_item_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if item != null:
				usage_panel.visible = !usage_panel.visible
				
		#dragging bind		
		if event.button_index == MOUSE_BUTTON_RIGHT :	
			if event.is_pressed():
				outer_border.modulate = Color(1,1,0)
				drag_start.emit(self)
			else:
				outer_border.modulate  = Color(1,1,1)
				drag_end.emit()
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_STRING   # we only accept the lie text

func _drop_data(_at_pos : Vector2, data: Variant) -> void:
	# visual flash
	modulate = Color(0,1,0,0.7)
	await get_tree().create_timer(0.2).timeout
	modulate = Color.WHITE

	# store in Global.hotbar_inventory (reuse your existing logic)
	var idx = Global.soup_slots.find(self)
	if idx == -1: return
	Global.hotbar_inventory[idx] = {
		"name": "Lie",
		"type": "speech",
		"effect": data,
		"quantity": 1,
		"texture": preload("res://ui/speech_bubble.png")
	}
	Global.inventory_updated.emit()


func _on_description_button_pressed() -> void:
	if item != null and item["description"] != "":
		print("Button Handler Activated")
		dialogue.dialogue_text[0] = ""
		dialogue.dialogue_text[0] = description
		print("Description :x" + str(description))
	
		dialogue.start_dialogue(Global.player)
	

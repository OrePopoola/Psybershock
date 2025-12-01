extends Control

@onready var hotbar_container = $HBoxContainer
var dragged_slot = null
func _ready():
	Global.inventory_updated.connect(_update_hotbar_ui)
	_update_hotbar_ui()
	Global.soup_slots = hotbar_container.get_children()
	print("Soup Slots" + str(Global.soup_slots))
func _process(delta):
	pass
	
func _update_hotbar_ui():
	clear_hotbar_container()
	for i in range(Global.hotbar_size):
		var slot = Global.inventory_slot_scene.instantiate()
		slot.set_slot_index(i)
		slot.drag_start.connect(_on_drag_start)
		slot.drag_end.connect(_on_drag_end)
		hotbar_container.add_child(slot)
		if Global.hotbar_inventory[i] != null:
			slot.set_item(Global.hotbar_inventory[i])
		else:
			slot.set_empty()
		slot.update_assignment_status()
		Global.soup_slots = hotbar_container.get_children()
	
func clear_hotbar_container():
	while hotbar_container.get_child_count() > 0:
		var child = hotbar_container.get_child(0)
		hotbar_container.remove_child(child)
		child.queue_free()
		
func _on_drag_start(slot_control : Control):
	dragged_slot = slot_control
	print("Dragged started from slot: ", dragged_slot)
func _on_drag_end():
	## get drop target
	var target_slot = get_slot_under_mouse()
	if target_slot and dragged_slot != target_slot:
		drop_slot(dragged_slot, target_slot)
	dragged_slot = null
func get_slot_under_mouse() -> Control:
	var mouse_position = get_global_mouse_position()
	for slot in hotbar_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	#var soup_target = get_soup_slot_under_mouse()
	#if soup_target and dragged_slot is DialogueLine:
	#	drop_into_soup(dragged_slot, soup_target)
	return null
#GROK code
#func drop_into_soup(dialogue_line: DialogueLine, soup_slot: Control):
	## copy the lie into the soup slot (just like assigning to hotbar)
	#var item_data = {
		#"name": "Lie",
		#"type": "speech",
		#"effect": dialogue_line.line_text,
		#"quantity": 1,
		#"icon": preload("res://UI/speech_bubble.png")
	#}
	#Global.hotbar_inventory[Global.soup_slots.find(soup_slot)] = item_data
	#Global.inventory_updated.emit()
#func get_soup_slot_under_mouse() -> Control:
	#var mp = get_global_mouse_position()
	#for slot in Global.soup_slots:
		#if slot and Rect2(slot.global_position, slot.size).has_point(mp):
			#return slot
	#return null	
	

func get_slot_index(slot: Control) -> int:
	for i in range(hotbar_container.get_child_count()):
		if hotbar_container.get_child(i) == slot:
			
			return i
		
	return -1
func drop_slot(slot1: Control, slot2 : Control):
	print("drop slot activated")
	var slot1_index = get_slot_index(slot1)
	var slot2_index = get_slot_index(slot2)
	if slot1_index == -1 or slot2_index == -1:
		print("invalid slots found")
		return
	else:
		if Global.swap_hotbar_items(slot1_index, slot2_index):
			print("Dropping slot items: ", slot1, slot2_index)
			_update_hotbar_ui()
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
		"icon": preload("res://ui/speech_bubble.png")
	}
	Global.inventory_updated.emit()

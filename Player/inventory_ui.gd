extends Control

@onready var grid_container = $GridContainer
# Called when the node enters the scene tree for the first time.

# Drag/Drop
var dragged_slot = null

func _ready() -> void:
	Global.inventory_updated.connect(_on_inventory_updated)
	_on_inventory_updated()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
func _on_inventory_updated():
	clear_grid_container()
	
	for item in Global.Inventory:
		var slot = Global.inventory_slot_scene.instantiate()
		
		slot.drag_start.connect(_on_drag_start)
		slot.drag_end.connect(_on_drag_end)
		grid_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()
		
func clear_grid_container():
	while grid_container.get_child_count():
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()
		
func _on_drag_start(slot_control : Control):
	dragged_slot = slot_control
	print("Dragged started from slot: ", dragged_slot)
func _on_drag_end():
	# get drop target
	var target_slot = get_slot_under_mouse()
	if target_slot and dragged_slot != target_slot:
		drop_slot(dragged_slot, target_slot)
	dragged_slot = null
func get_slot_under_mouse() -> Control:
	var mouse_position = get_global_mouse_position()
	for slot in grid_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	var soup_target = get_soup_slot_under_mouse()
	if soup_target and dragged_slot is DialogueLine:
		drop_into_soup(dragged_slot, soup_target)
	return null
#GROK code
func drop_into_soup(dialogue_line: DialogueLine, soup_slot: Control):
	# copy the lie into the soup slot (just like assigning to hotbar)
	var item_data = {
		"name": "Lie",
		"type": "speech",
		"effect": dialogue_line.line_text,
		"quantity": 1,
		"icon": preload("res://UI/speech_bubble.png")
	}
	Global.hotbar_inventory[Global.soup_slots.find(soup_slot)] = item_data
	Global.inventory_updated.emit()
func get_soup_slot_under_mouse() -> Control:
	var mp = get_global_mouse_position()
	for slot in Global.soup_slots:
		if slot and Rect2(slot.global_position, slot.size).has_point(mp):
			return slot
	return null	
	

func get_slot_index(slot: Control) -> int:
	for i in range(grid_container.get_child_count()):
		if grid_container.get_child(i) == slot:
			
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
		if Global.swap_inventory_items(slot1_index, slot2_index):
			print("Dropping slot items: ", slot1, slot2_index)
			_on_inventory_updated()

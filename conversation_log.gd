extends Control
class_name ConversationLog

@onready var label: RichTextLabel = $VBoxContainer/DialogueLabel
@onready var next_btn: Button = $VBoxContainer/NextButton
# ------------------------------------------------------------------
# 1. Fill this array in the inspector (or load from JSON)
@export var lines: Array[String] = [
	"Welcome to the mind of the killer.",
	"He says: **I never hurt anyone.**",
	"You notice a flicker in his eyes.",
	"He adds: **The knife was clean.**",
    "That's the last thing he says."
]
# ------------------------------------------------------------------


#@onready var lines_container: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer

# Called from TurnManager when a line is spoken
#func add_line(speaker: String, text: String, is_lie: bool = false) -> void:
	#var line = preload("res://UI/dialogue_line.tscn").instantiate()
	#line.setup(speaker, text, is_lie)
	#lines_container.add_child(line)
	## scroll to bottom
	#await get_tree().process_frame
	#$VBoxContainer/ScrollContainer.scroll_vertical = $VBoxContainer/ScrollContainer.get_v_scroll_bar().max_value
	
	
var current_idx := -1
var current_rich_line := ""   # BBCode version

func _ready() -> void:
	label.bbcode_enabled = true
	label.meta_underlined = true
	label.fit_content = true
	#label.connect("meta_clicked", Callable(self, "_on_dialogue_label_meta_clicked"))
	
	
	next_btn.pressed.connect(_next_line)
	#$VBoxContainer/DialogueLabel.meta_clicked.connect(_on_dialogue_label_meta_clicked)
	#Global.soup_slots = get_tree().get_nodes_in_group("soup_slot")  # optional group
	_next_line()   # show first line

func _next_line() -> void:
	current_idx += 1
	if current_idx >= lines.size():
		next_btn.visible = false
		return

	var raw = lines[current_idx]
	current_rich_line = _parse_lies(raw)
	label.clear()
	label.append_text(current_rich_line)
	
# ------------------------------------------------------------------
# 2. Turn **word** into a draggable token
func _parse_lies(raw: String) -> String:
	var parts := raw.split("**", true)
	var bbcode := ""
	var in_lie := false
	for i in parts.size():
		var txt := parts[i]
		if in_lie:
			# ---- make a draggable token ----
			var token_id := "lie_%d_%d" % [current_idx, i]
			bbcode += "[url=%s][u][color=#ff6666]%s[/color][/u][/url]" % [token_id, txt]
		else:
			bbcode += txt
		in_lie = !in_lie
	return bbcode

# ------------------------------------------------------------------
# 3. RichTextLabel meta-click → start drag

func _extract_lie_text(token_id: String) -> String:
	# token_id = "lie_3_1" → line 3, second ** block
	var parts = token_id.split("_")
	var line_idx = int(parts[1])
	var block_idx = int(parts[2])
	var raw = lines[line_idx]
	var lie_parts = raw.split("**")
	if block_idx * 2 + 1 < lie_parts.size():
		return lie_parts[block_idx * 2 + 1]
	return ""


func _on_dialogue_label_meta_clicked(meta: Variant) -> String:
	print("TESTING SPEECH DRAG")
	print(meta)
	var item_type  = "possible lie"
	var item_name = "Artifact"
	var item_texture ="res://UI/speech_bubble.png"
	var item_effect  = "place in crafting"
	var item = {
		"quantity" : 1,
		"type" : item_type,
		"name" : item_name,
		"texture" : item_texture,
		"effect" : item_effect,
		"scene_path" : "res://Global/Inventory_Item_3d.tscn",
		"description" : " The enemy is slipping up",
	}
	Global.add_item(item, true)
	
	
	var token_id: String = meta
	# find the exact text that belongs to this token
	var lie_text := _extract_lie_text(token_id)
	print("lie text" + str(lie_text))
	if lie_text.is_empty(): return ""

	# create a tiny draggable preview
	var preview = Panel.new()
	preview.custom_minimum_size = Vector2(180, 36)
	var lbl = Label.new()
	lbl.text = lie_text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	preview.add_child(lbl)
	set_drag_preview(preview)
	# payload = the lie text itself
	return lie_text
############## More Grok

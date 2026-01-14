extends Control
class_name ConversationLog

@onready var label: RichTextLabel = $VBoxContainer/DialogueLabel
@onready var next_btn: Button = $VBoxContainer/NextButton

# ------------------------------------------------------------------
# 1. Use **text** for lies (safe), ##text## for truths (dangerous but look identical)
@export var lines: Array[String] = [
	"Athena: Hello Tobias, my name is Athena, and I'll be your therapist for today.\n",
	"I'll start with a get to know you, and then we'll move on from there.\n",
	"Tell me about yourself.\n",
	"Tobias: Well, I was born in **the richer section of Belgrade, New Turkey**. To black and asian parents\n ",
	"Despite my upbringing, I grew up tough and alone, I don't have any memories **of friends that I treasure**\n",
	"He says: **I never and have never hurt anyone.** Pacifism is at the core of my style,my conceit\n",
	"What you probabally won't find in your Case Notes is that I was a frontline protester at the Ankaran University Shootings\n",
	"Athena: You would've been 16 years old then\n",
	"Tobias: Which is why it is so crucial for me to tell you",
	"You notice a flicker in his eyes. \n",
	"I don't really even need a therapist, but I do need a friend.\n",  # ← This is a truth, but looks red like a lie
	"Athena: I want you to know that everything is confidential. And that I want you to feel comfortable ",
	"telling the whole truth to me",
]
var current_idx := -1
var current_rich_line := ""

func _ready() -> void:
	label.bbcode_enabled = true
	label.meta_underlined = true
	label.fit_content = true
	next_btn.pressed.connect(_next_line)
	label.meta_clicked.connect(_on_dialogue_label_meta_clicked)  # Make sure this is connected
	_next_line()

func _next_line() -> void:
	current_idx += 1
	if current_idx >= lines.size():
		next_btn.visible = false
		return
	var raw = lines[current_idx]
	current_rich_line = _parse_tokens(raw)  # ← now handles both ** and ##
	label.append_text(current_rich_line)    # append, not clear (in case you add multiple lines later)

# ------------------------------------------------------------------
# 2. Parse both **lies** and ##truths## → both become red clickable tokens
func _parse_tokens(raw: String) -> String:
	var bbcode := ""
	var pos := 0
	
	while pos < raw.length():
		# Find next opening marker: ** or ##
		var lie_pos = raw.find("**", pos)
		var truth_pos = raw.find("##", pos)
		
		var next_pos = -1
		var marker = ""
		if lie_pos != -1 and (truth_pos == -1 or lie_pos < truth_pos):
			next_pos = lie_pos
			marker = "**"
		elif truth_pos != -1:
			next_pos = truth_pos
			marker = "##"
		
		# Add normal text before the marker
		if next_pos != -1:
			bbcode += raw.substr(pos, next_pos - pos)
		
		if next_pos == -1:
			bbcode += raw.substr(pos)
			break
		
		# Find closing marker
		var close_pos = raw.find(marker, next_pos + 2)
		if close_pos == -1:
			bbcode += raw.substr(next_pos)
			break
		
		var content = raw.substr(next_pos + 2, close_pos - next_pos - 2)
		
		# Same visual style for both (red)
		var token_id := "token_%d_%d_%s" % [current_idx, bbcode.length(), "lie" if marker == "**" else "truth"]
		
		bbcode += "[url=%s][u][color=#ff6666]%s[/color][/u][/url]" % [token_id, content]
		
		pos = close_pos + 2
	
	return bbcode

# ------------------------------------------------------------------
# 3. Extract the original text from token_id
func _extract_token_text(token_id: String) -> String:
	var parts = token_id.split("_")
	if parts.size() < 4:
		return ""
	var line_idx = int(parts[1])
	var marker = "**" if parts[3] == "lie" else "##"
	
	var raw = lines[line_idx]
	var start = 0
	while true:
		var open_pos = raw.find(marker, start)
		if open_pos == -1: break
		var close_pos = raw.find(marker, open_pos + 2)
		if close_pos == -1: break
		var content = raw.substr(open_pos + 2, close_pos - open_pos - 2)
		# Simple match: return first one (or improve with index if needed)
		# Since your original used block_idx, this approximates it
		return content
		start = close_pos + 2
	return ""

# ------------------------------------------------------------------
# 4. Click handler — adds item to inventory with hidden is_lie flag
func _on_dialogue_label_meta_clicked(meta: Variant) -> String:
	print("TESTING SPEECH DRAG")
	print(meta)
	
	var token_id: String = str(meta)
	var token_text := _extract_token_text(token_id)
	print("token text: " + token_text)
	if token_text.is_empty():
		return ""
	
	# Determine if it's actually a lie or a truth
	var is_lie := token_id.contains("_lie")
	
	var item = {
		"quantity" : 1,
		"type" : "possible lie",
		"name" : "Artifact",
		"texture" : "res://UI/speech_bubble.png",
		"effect" : "place in crafting",
		"scene_path" : "res://Global/Inventory_Item_3d.tscn",
		"description" : "The enemy is slipping up",
		"text" : token_text,
		"is_lie" : is_lie  # ← Crucial for crafting logic later!
	}
	Global.add_item(item, true)
	
	# Drag preview (shows the text)
	var preview = Panel.new()
	preview.custom_minimum_size = Vector2(180, 36)
	var lbl = Label.new()
	lbl.text = token_text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	preview.add_child(lbl)
	set_drag_preview(preview)
	
	return token_text

extends Control
class_name DialogueLine

@onready var icon: TextureRect = $HBoxContainer/SpeakerIcon
@onready var label: RichTextLabel = $HBoxContainer/Text
@onready var handle: TextureRect = $HBoxContainer/DragHandle

var is_lie: bool = false
var line_text: String

func setup(speaker: String, text: String, lie: bool):
	is_lie = lie
	line_text = text
	var color = "#ff6666" if speaker == "Killer" else "#66ccff"
	label.text = "[color=%s]%s:[/color] %s" % [color, speaker, text]
	handle.visible = lie
	if lie:
		handle.texture = preload("res://UI/drag_handle.png")   # small hand icon
		tooltip_text = "Drag this lie into the soup!"

# ---------- DRAG LOGIC ----------
var drag_preview: Control = null

func _get_drag_data(_at_position):
	if not is_lie: return null                     # block non-lies
	# create preview
	drag_preview = Panel.new()
	drag_preview.custom_minimum_size = Vector2(300, 40)
	var lbl = Label.new()
	lbl.text = line_text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	drag_preview.add_child(lbl)
	set_drag_preview(drag_preview)
	return self                                    # the whole node is the payload

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		if drag_preview: drag_preview.queue_free()

extends Node3D

var in_dialogue = false
var player_in_range = false

var index = 0
var current_player = null
var is_typing = false  # Tracks if text is currently being typed
var current_text = ""  # Stores the full text of the current line
var current_char_index = 0  # Tracks the current character position
var typing_speed = 0.1  # Time (in seconds) between each character
var dialogueCopy = []
var insideBounds = false
var dialogueLines = []

@export var dialogue_text: Array[String] = [] # Array of dialogue lines
@export var material: Material = null # Material for the 3D mesh
@onready var timer = $Timer
 # Reference to the 3D mesh

func _ready():
	# Apply material to the MeshInstance3D (assumes a QuadMesh or similar)
	
	# Initialize dialogue copy and timer
	dialogueCopy = dialogue_text.duplicate()
	timer.wait_time = typing_speed
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)

func start_dialogue(body):
	in_dialogue = true
	current_player = body
	print("Body: " +str(body))
	print("Start_dialogue entered!")
	if current_player.dialogue_ui:
		print("Check One")
		current_player.dialogue_ui.visible = true
		print(current_player.dialogue_ui.visible)
		current_player.dialogue_text.text = current_text
		print("Current Text: " +str(current_text))
		print("Check Two")
	#if index < len(dialogue_text) and player_in_range: Old Version
	if index < len(dialogue_text):
		current_text = dialogue_text[index]  # Store the current line
		current_char_index = 0  # Reset character index
		dialogue_text[index] = ""  # Clear the text
		is_typing = true  # Start typing
		timer.start()  # Start the timer for character-by-character display
	else:
		cleanup()

func _on_timer_timeout():
	print("Entered Timeout")
	if is_typing and current_char_index < len(current_text):
		# Add one character at a time
		dialogue_text[index] += current_text[current_char_index]
		current_char_index += 1
		if current_player and current_player.dialogue_text:
			current_player.dialogue_text.text = dialogue_text[index]
		if current_char_index >= len(current_text): # Line is finished
			is_typing = false
			timer.stop()
			index += 1  # Move to the next line
			if index >= len(dialogue_text):
				index = 0  # Reset dialogue when done
	else:
		is_typing = false
		timer.stop()

func _process(delta):
	if Input.is_action_just_pressed("Cancel"):
		cleanup()
	if in_dialogue and Input.is_action_just_pressed("Talk"): #and player_in_range:
		if is_typing:
			# Show the full line immediately
			dialogue_text[index] = current_text
			if current_player and current_player.dialogue_text:
				current_player.dialogue_text.text = current_text
			current_char_index = len(current_text)
			is_typing = false
			timer.stop()
			index += 1
		else:
			# Start the next line
			if index < len(dialogue_text):
				current_text = dialogue_text[index]
				current_char_index = 0
				dialogue_text[index] = ""
				if current_player and current_player.dialogue_text:
					current_player.dialogue_text.text = ""
				is_typing = true
				timer.start()
			else:
				cleanup()
	
		

func cleanup():
	print("Entered cleanup")
	if current_player and current_player.dialogue_ui:
		current_player.dialogue_ui.visible = false
	in_dialogue = false
	index = 0
	is_typing = false
	timer.stop()
	dialogue_text = dialogueCopy.duplicate()

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("reading from the 3D Dialogue")
	if body.is_in_group("Player"):
		player_in_range = true
		current_player = body
		insideBounds = true
		print("Area 3D Entered!")
		# Optionally, start dialogue immediately or wait for input
		start_dialogue(body) # Uncomment if you want dialogue to start automatically

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		insideBounds = false
		cleanup()


func _on_description_button_pressed() -> void:
	current_player = Global.player
	print("Area 3D Entered!")
		# Optionally, start dialogue immediately or wait for input
	start_dialogue(current_player) # Uncomment if you want dialogue to start automatically

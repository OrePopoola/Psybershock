extends Node2D
var in_dialogue = false
var player_in_range = false


var index = 0
var current_player = null
var is_typing = false  # Tracks if text is currently being typed
var current_text = ""  # Stores the full text of the current line
var current_char_index = 0  # Tracks the current character position
var typing_speed = 0.1  # Time (in seconds) between each character TODO change back to .05
var dialogueCopy =[]
var insideBounds = false
var dialogueLines = []
@export var dialogue_text : Array[String] = [] # Reference to your Label or RichTextLabel
@export var texture : Texture2D = null
@onready var timer = $Timer
@onready var currentTexture = $Area2D/Sprite2D
func _ready():
	currentTexture.texture =texture
	dialogueCopy = dialogue_text
	timer.wait_time = typing_speed
	timer.one_shot = false
	timer.connect("timeout", _on_timer_timeout)
	
func start_dialogue(body):
	
	#print("Entered function")
	in_dialogue = true
	current_player = body
	current_player.dialogue_ui.visible = true
	current_player.dialogue_text.text = current_text
	#print(dialogue_text)
	
	if index < len(dialogue_text[index]) and player_in_range: # we are iterating through a speech fragment
		current_text = dialogue_text[index]  # Store the current line
		current_char_index = 0  # Reset character index
		dialogue_text[index] = ""  # Clear the text
		
		is_typing = true  # Start typing
		timer.start()  # Start the timer for character-by-character display
	else:
		#print("Start cleanup")
		cleanup()	
	
func _on_timer_timeout():
	#print("in timeout")
	if is_typing and current_char_index < (len(current_text)):
		# Add one character at a time
		#print("Current char index:")
		#print(dialogue_text)
		#print("Current text :" +current_text)
		dialogue_text[index] += current_text[current_char_index]
		current_char_index += 1
		current_player.dialogue_text.text = dialogue_text[index]
		if current_char_index >= (len(current_text)): # if line is finished
			# Finished typing the current line
			is_typing = false
			timer.stop()
			index += 1  # Move to the next line
			if index >= len(dialogue_text):
				index = 0  # Reset dialogue when done
	else:
		is_typing = false
		timer.stop()
func _startPress(body):
	if insideBounds and Input.is_action_just_pressed("Talk"):
		start_dialogue(body)
func _process(delta):
	#if insideBounds and Input.is_action_just_pressed("Talk"):
	#	start_dialogue(current_player)
	#startPress(cur)
	if in_dialogue and Input.is_action_just_pressed("Talk") and player_in_range:
		if is_typing:
			# If player presses a key while typing, show the full line immediately
			dialogue_text[index] = current_text
			current_player.dialogue_text.text = current_text
			current_char_index = len(current_text)
			is_typing = false
			timer.stop()
			index += 1
		else:
			# Start the next line
			#print("starting second line")
			#print(len(dialogue_text))
			if index < len(dialogue_text):
				current_text = dialogue_text[index]
				current_char_index = 0
				dialogue_text[index] = ""
				current_player.dialogue_text.text = ""
				is_typing = true
				timer.start()
				index + 1
			else:
				#print("process cleanup")
				cleanup()
func cleanup():
	#print("Cleanup triggered")
	if current_player:
		current_player.dialogue_ui.visible = false
	in_dialogue = false
	index = 0
	is_typing = false
	timer.stop()
	dialogue_text = dialogueCopy


	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		current_player = body
		insideBounds = true
		print("loaded")
		start_dialogue(body)# should this be activated with a 'Talk' press


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		insideBounds = false
		cleanup()

extends CharacterBody2D


# We are trying to replicate Superbrothers Sword and Sorcery. Our character is going to navigate a 2.5d pane that will sometimes be two dimensional
# However in any circumstance the chracter will actually only ever be navigating a topdown grid similar zelda
# However this grid should have the ability to turn into a platformer, we will determine this depending on whether the character enters a certain flag
#which will enable gravity. And when this happens the the animations will also change. 
#For example a imagine a cube navigating a topdown zelda plane, then passing an Area2D enableing 
@onready var interact_ui = $InteractUI
@onready var animated_sprite = $AnimatedSprite2D
@onready var inventory_ui = $InventoryUI
@onready var dialogue_ui = $DialogueUI
@onready var dialogue_text = $DialogueUI/ColorRect/Label
@export var grav_on := false
var ladder = false
const SPEED = 100.0
const JUMP_VELOCITY = -400.0
var count = 0

func _input(event):
	if event.is_action_pressed("Inventory"):
		inventory_ui.visible = !inventory_ui.visible
		#get_tree().paused = !get_tree().paused
	#if event.is_action_pressed("Talk"):
		#count += 1
		#dialogue_ui.visible = !dialogue_ui.visible
		#dialogue_text.text = "Hello World!"
#func get_input():
	
	
	#velocity = Vector2()
	#if Input.is_action_pressed('right'):
	#	velocity.x += 1
	#elif Input.is_action_pressed('left'):
#	velocity.x -= 1
#	elif Input.is_action_pressed('down'):
#		velocity.y += 1
#	elif Input.is_action_pressed('up'):
#		velocity.y -= 1
#	velocity = velocity.normalized() * SPEED

func animate_movement(x,y):
	if( y > 0) and not grav_on and !ladder:
		animated_sprite.play("Walk downward")
	elif( y > 0) and not grav_on and ladder:
		animated_sprite.play("climbing")
	elif( y < 0) and not grav_on and !ladder:
		animated_sprite.play("walk upward")
	elif( y < 0) and not grav_on and ladder:
		animated_sprite.play("climbing")
	elif( x > 0):
		animated_sprite.play(" Run Right")
		animated_sprite.flip_h = false
	elif (x < 0 ):
		animated_sprite.play(" Run Right")
		animated_sprite.flip_h = true
	elif x == 0 and y == 0:
		# add initially Standing then wait
		animated_sprite.play("Idle")
func _process(delta):
	# Get the global mouse position
	var mouse_pos = get_global_mouse_position()
	# Option 1: Use look_at() for simple rotation	
	#look_at(mouse_pos)
		
	# Option 2: Manually calculate the angle (if you need more control)
	# var direction = mouse_pos - global_position
	# rotation = direction.angle()
	# If your sprite faces up by default, add a 90-degree offset (in radians)
	#rotation += deg_to_rad(90)	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if grav_on and not is_on_floor() :
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Move Left", "Move Right")
	# make sure to mod this so that people cant walk downward in 2d platformer space
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if Input.is_action_pressed('Move Up') and not grav_on:
		velocity.y = SPEED * -1
	elif Input.is_action_pressed('Move Down') and not grav_on:
		velocity.y = SPEED 
	elif not grav_on:
		velocity.y = 0
		
	animate_movement(velocity.x,velocity.y)
		

	move_and_slide()

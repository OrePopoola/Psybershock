extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_gravity_enabler_body_entered(body: Node2D) -> void:
	print("enabler entered")
	if("grav_on" in body):
		body.grav_on = true
		print("gravity altered")


func _on_gravity_disabler_body_entered(body: Node2D) -> void:
	print("disabler exited")
	if("grav_on" in body):
		body.grav_on = false
		print("gravity altered")

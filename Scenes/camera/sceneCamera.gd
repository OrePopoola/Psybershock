extends Camera2D

@onready var CameraManager : Node2D = $".."
@onready var thisCamera : Camera2D = $"."
signal camera_entered(sceneCamera)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# send a signal to CameraManafunc switch_camera()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#camera_entered.emit(thisCamera) TEMPORARY
		print(body)
		#print("entered")
		thisCamera.enabled = true
	# send switch signal to CameraManager
pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	thisCamera.enabled = false

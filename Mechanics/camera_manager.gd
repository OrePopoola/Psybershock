extends Node2D
# Replace this with a list of cameras


@onready var camera2d :Camera2D = $Camera2D
@onready var camera_manager: Node2D =$"."
var activeCamera :Camera2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_get_initial_camera(camera_manager)
	

func _get_initial_camera(node: Node2D) -> void:
	for N in node.get_children():
		if N is Camera2D:
			if N.enabled == true:
				activeCamera = N
				break
				

func _camera_switch(from: Camera2D, to: Camera2D) -> void:
	from.enabled = false
	to.enabled = true
	print("switching camera")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_camera_2d_camera_entered(sceneCamera: Variant) -> void:
	if(sceneCamera.is_current() == false):
		print("switching camera")
		_camera_switch(activeCamera, sceneCamera)
	activeCamera = sceneCamera
	

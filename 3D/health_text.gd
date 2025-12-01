extends Label
@onready var player = $"../.."
var health
var max_health
func _ready():
	pass
	
func _process(_delta):
	health = player.health
	max_health = player.max_health
	$".".text = "Health: " + str(health) + "/" + str(max_health)

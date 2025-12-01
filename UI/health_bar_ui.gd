extends CanvasLayer
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar

var tween: Tween
var animated_health: float = 100.0

func _ready() -> void:
	# Get player reference (adjust path to your player node)
	var player = Global.player # Or use autoload/singleton
	if player:
		health_bar.max_value = player.max_health
		animated_health = player.health
		update_display()

	# Connect player's health_changed signal
	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_player_health_changed)
func _on_player_health_changed(new_health: float) -> void:
	# Animate smoothly to new health
	tween = create_tween()
	tween.tween_property(self, "animated_health", new_health, 0.6).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _process(_delta: float) -> void:
	update_display()

func update_display() -> void:
	var rounded = round(animated_health)
	health_bar.value = rounded

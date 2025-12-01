extends Control
@export var damage_amount: int = 0
@export var crit: bool = false
@export var color: Color = Color.WHITE

func _ready():
	$Label.text = str(damage_amount)
	if crit:
		$Label.text += "!"  # Optional flair
		scale = Vector2(1.4, 1.4)
		modulate = Color.GOLD  # Affects whole control

	$Label.modulate = color

	# Float upward + fade + shrink
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "position:y", position.y - 60, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.7).set_delay(0.2)
	tween.tween_property(self, "scale", scale * 0.7, 0.8)
	tween.chain().tween_callback(queue_free)

	$Timer.start(1.2)  # Backup delete

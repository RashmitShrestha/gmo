extends Node2D

@onready var label: Label = $Label

var velocity: Vector2 = Vector2.ZERO
var gravity: float = 100.0
var fade_speed: float = 2.0

func _ready() -> void:
	# Random horizontal drift for variety
	velocity = Vector2(randf_range(-30, 30), -80)
	
	# Auto-destroy after animation
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	# Float upward with slight gravity
	velocity.y += gravity * delta
	position += velocity * delta

func set_damage(amount: int, color: Color = Color.WHITE, is_crit: bool = false) -> void:
	label.text = str(amount)
	label.self_modulate = color
	
	if is_crit:
		label.add_theme_font_size_override("font_size", 28)
		label.text += "!!!"
		if color == Color.WHITE:
			label.self_modulate = Color.YELLOW

func set_heal(amount: int):
	label.text = "+" + str(amount)
	label.self_modulate = Color(0.3, 1.0, 0.3)
	label.add_theme_font_size_override("font_size", 24)

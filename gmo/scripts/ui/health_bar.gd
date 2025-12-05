extends Control

@export var delayed: TextureProgressBar
@export var exact: TextureProgressBar

var _max_health: float
var _curr_health: float

var shaking: bool = false
var original_position: Vector2 = Vector2.ZERO
var shake_strength: int = 7
var shake_speed: float = 0.05

@onready var vignette: ShaderMaterial = $"../VignetteLayer/ColorRect".material

func _ready() -> void:
	_max_health = 100.0
	_curr_health = 100.0
	
	original_position = position
	
	SignalBus.connect("player_health_changed", _on_health_changed)
	
	# force vignette to hide before rendering
	vignette.set_shader_parameter("MainAlpha", 0.0)


func _on_health_changed(new_health: float, max_health: float) -> void:
	if new_health < _curr_health:
		shake_bar()
	
	_max_health = max_health
	_curr_health = new_health
	
	exact.value = new_health
	
	update_vignette(new_health, max_health)


func _process(delta: float) -> void:
	delayed.value = lerpf(delayed.value, _curr_health, 4 * delta)


func shake_bar():
	if shaking: 
		return
		
	shaking = true
	
	var tween = create_tween()
	
	for i in range (2):
		var offset = Vector2(-shake_strength, 0)
		tween.tween_property(self, "position", original_position + offset, shake_speed)
		var offset2 = Vector2(shake_strength, 0)
		tween.tween_property(self, "position", original_position + offset2, shake_speed)
	
	tween.tween_property(self, "position", original_position, shake_speed)
	
	tween.tween_callback(func():
		shaking = false
	)
	
	
func update_vignette(health: float, max_health: float):
	var opacity: float = 0.0
	var hp_ratio = health / max_health
	
	# red vignette starts appearing at 20% health
	opacity = clamp ((0.3 - hp_ratio) / 0.3, 0.0, 1)
	
	vignette.set_shader_parameter("MainAlpha", opacity)

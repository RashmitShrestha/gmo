extends Control

@export var delayed: TextureProgressBar
@export var exact: TextureProgressBar

var _max_health: float
var _curr_health: float

func _ready() -> void:
	_max_health = 100.0
	_curr_health = 100.0
	
	SignalBus.connect("player_health_changed", _on_health_changed)


func _on_health_changed(new_health: float, max_health: float) -> void:
	_max_health = max_health
	_curr_health = new_health
	
	exact.value = new_health


func _process(delta: float) -> void:
	delayed.value = lerpf(delayed.value, _curr_health, 4 * delta)

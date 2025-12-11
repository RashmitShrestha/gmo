extends TextureProgressBar


func _ready() -> void:
	SignalBus.base_health_changed.connect(_update_health)
	_update_health(50000.0, 50000.0)


func _update_health(new_health: float, max_health: float):
	value = new_health
	max_value = max_health

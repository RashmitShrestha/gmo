extends CanvasLayer

@onready var message_label: Label = $CenterContainer/MessageLabel

func _ready() -> void:
	visible = false
	SignalBus.wave_completed.connect(_on_wave_completed)
	SignalBus.wave_started.connect(_on_wave_started)

func _on_wave_completed(wave_number: int) -> void:
	show_message("WAVE %d CLEARED!" % wave_number)

func _on_wave_started(wave_number: int) -> void:
	show_message("WAVE %d STARTING!" % wave_number, 3.0)

func show_message(text: String, duration: float = 3.0) -> void:
	message_label.text = text
	visible = true
	
	message_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 1.0, 0.3)

	await get_tree().create_timer(duration).timeout

	var fade_out = create_tween()
	fade_out.tween_property(message_label, "modulate:a", 0.0, 0.5)
	await fade_out.finished
	
	visible = false


extends CanvasLayer


@onready var title: Label = $CenterContainer/VBoxContainer/Title
@onready var kills_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/Kills
@onready var wave_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/WaveBonuses
@onready var health_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/HealthBonuses
@onready var time_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/PlayTime
@onready var separator: HSeparator = $CenterContainer/VBoxContainer/Panel/VBoxContainer/HSeparator
@onready var total_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/TotalScore


func _ready() -> void:
	visible = false

	SignalBus.all_waves_completed.connect(func(): show_screen(true))
	SignalBus.player_died.connect(func(): show_screen(false))


func show_screen(is_victory: bool) -> void:
	if is_victory:
		title.text = "VICTORY!"
		title.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))  # Green
	else:
		title.text = "GAME OVER"
		title.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))  # Red

	var breakdown = ScoreManager.get_score_breakdown()

	kills_label.text = "Enemy Kills: %d" % breakdown.kills_score
	wave_label.text = "Wave Bonuses: %d" % breakdown.wave_bonuses
	health_label.text = "Health Bonuses: %d" % breakdown.health_bonuses
	time_label.text = "Time: %s" % breakdown.formatted_time
	total_label.text = "TOTAL SCORE: %d" % breakdown.total_score

	visible = true

	get_tree().paused = true

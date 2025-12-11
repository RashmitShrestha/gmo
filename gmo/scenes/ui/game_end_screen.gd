extends CanvasLayer


@onready var title: Label = $CenterContainer/VBoxContainer/Title
@onready var kills_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/Kills
@onready var wave_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/WaveBonuses
@onready var health_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/HealthBonuses
@onready var time_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/PlayTime
@onready var separator: HSeparator = $CenterContainer/VBoxContainer/Panel/VBoxContainer/HSeparator
@onready var total_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/TotalScore
@onready var xp_label: Label = $CenterContainer/VBoxContainer/Panel/VBoxContainer/TotalXP


func _ready() -> void:
	visible = false

	SignalBus.all_waves_completed.connect(func(): show_screen(true))
	SignalBus.game_over.connect(func(): show_screen(false))


func show_screen(is_victory: bool) -> void:
	var breakdown = ScoreManager.get_score_breakdown()
		
	if is_victory:
		title.text = "VICTORY!"
				#used ai for the line below
		title.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))  # Green
	else:
		title.text = "GAME OVER - Wave %d" % breakdown.current_wave
				#used ai for the line below this one as well
		title.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))  # Red

	var xp_breakdown = ScoreManager.get_xp_breakdown()

	kills_label.text = "Enemy Kills: %d" % breakdown.kills_score
	wave_label.text = "Wave Bonuses: %d" % breakdown.wave_bonuses

	if breakdown.death_count > 0:
		health_label.text = "Deaths: %d (-%d points)" % [breakdown.death_count, breakdown.death_penalty]
	else:
		health_label.text = "Deaths: Flawless"

	time_label.text = "Time: %s" % breakdown.formatted_time
	total_label.text = "TOTAL SCORE: %d" % breakdown.total_score
	xp_label.text = "TOTAL XP EARNED: %d" % xp_breakdown.total_xp

	print("XP Breakdown:")
	print("  Kills XP: %d" % xp_breakdown.kills_xp)
	print("  Wave XP: %d" % xp_breakdown.wave_xp)
	print("  Health Bonus XP: %d" % xp_breakdown.health_bonus_xp)
	print("  Damage Avoidance XP: %d" % xp_breakdown.damage_bonus_xp)
	print("  Speed Bonus XP: %d" % xp_breakdown.speed_bonus_xp)

	visible = true

	get_tree().paused = true

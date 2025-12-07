class_name SkillSelection

static func apply_skill_effect(skill_id: String) -> void:
	match skill_id:
		# FLAME PATH
		"+10% Attack":
			SignalBus.emit_signal("stat_modified", "player", "attack", 1.10)
			
		"1_trail":  # Torched and Tender
			SignalBus.emit_signal("ability_toggled", "flame_trail", true, {
				"duration": 3.0,
				"burn_duration": 2.0
			})
			
		"1_trail_upgrade":  # Broiled Brutality
			SignalBus.emit_signal("ability_toggled", "flame_trail", true, {
				"duration": 5.0,
				"burn_duration": 2.0,
				"burn_damage_multiplier": 2.0
			})
			
		"1_status1":  # Caramelized Cruelty
			SignalBus.emit_signal("status_effect_applied", "player", "burn_crit_boost", {
				"crit_chance_bonus": 0.20,
				"crit_damage_bonus": 0.20
			})
			
		"1_ability":  # Flaming Finger
			SignalBus.emit_signal("ability_toggled", "flame_flinger", true, {
				"range": 100,
				"damage": 10,
				"directions": 1
			})
			
		"1_ability_upgrade":  # Flambéed Fury
			SignalBus.emit_signal("ability_toggled", "flame_flinger", true, {
				"range": 200,
				"damage": 20,
				"directions": 4
			})
			
		"1_status2":  # Searing Indignation
			SignalBus.emit_signal("status_effect_applied", "player", "consecutive_hit_boost", {
				"crit_dmg_per_hit": 0.01,
				"crit_chance_per_hit": 0.01,
				"atk_per_hit": 0.01,
				"reset_window": 0.5
			})
		
		# FROST PATH
		"+10% Movement Speed":
			SignalBus.emit_signal("stat_modified", "player", "movement_speed", 1.10)
			
		"2_trail":  # Crystallized Cascade
			SignalBus.emit_signal("ability_toggled", "frost_trail", true, {
				"duration": 3.0,
				"slow_percent": 0.5
			})
			
		"2_trail_upgrade":  # Permafrost Promenade
			SignalBus.emit_signal("ability_toggled", "frost_trail", true, {
				"duration": 5.0,
				"slow_percent": 0.75
			})
			
		"2_status1":  # Frostbite Fracture
			SignalBus.emit_signal("status_effect_applied", "player", "freeze_on_hit", {
				"freeze_chance": 1
			})
			
		"2_ability":  # Frame Freeze
			SignalBus.emit_signal("ability_toggled", "freeze_frame", true, {
				"duration": 4.0,
				"freeze_projectiles": false
			})
			
		"2_ability_upgrade":  # Nitrogen Nirvana
			SignalBus.emit_signal("ability_toggled", "freeze_frame", true, {
				"duration": 7.0,
				"speed_multiplier": 2.0,
				"unlimited_range": true
			})
			
		"2_status2":  # Refrigerated Reflexes
			SignalBus.emit_signal("stat_modified", "enemies", "movement_speed", 0.6)
		
		# FERMENT PATH
		"+10% Health":
			SignalBus.emit_signal("stat_modified", "player", "max_health", 1.10)
			
		"3_trail":  # Leeching Loam
			SignalBus.emit_signal("ability_toggled", "ferment_trail", true, {
				"duration": 3.0,
				"lifesteal_enabled": true
			})
			
		"3_trail_upgrade":  # Vitamin Vampirism
			SignalBus.emit_signal("ability_toggled", "ferment_trail", true, {
				"duration": 5.0,
				"lifesteal_enabled": true,
				"atk_siphon_percent": 0.10
			})
			
		"3_status1":  # Regenerative Realization
			SignalBus.emit_signal("status_effect_applied", "player", "health_regen", {
				"amount": 2,
				"interval": 10.0
			})
			
		"3_ability":  # Fertilized Farm
			SignalBus.emit_signal("ability_toggled", "ally_fruit_spawn", true, {
				"spawn_duration": 5.0,
				"ally_lifetime": 10.0
			})
			
		"3_ability_upgrade":  # Vineyard Vengeance
			SignalBus.emit_signal("status_effect_applied", "player", "ally_stat_boost", {
				"multiplier": 2.0
			})
			
		"3_status2":  # Hard to Peel
			SignalBus.emit_signal("status_effect_applied", "player", "recharging_shield", {
				"recharge_time": 10.0
			})
		
		_:
			print("Skill effect not implemented: ", skill_id)

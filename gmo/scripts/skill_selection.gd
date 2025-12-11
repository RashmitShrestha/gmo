class_name SkillSelection

static func apply_skill_effect(skill_id: String) -> void:
	match skill_id:
		# FLAME PATH
		"+10% Attack":
			SignalBus.emit_signal("stat_modified", "player", "attack", 1.10)
			
		"1_trail": 
			SignalBus.emit_signal("ability_toggled", "flame_trail", true, {
				"duration": 5.0,
				"burn_duration": 2.0,
				"burn_damage_multiplier": 10.0
			})
			
		"1_trail_upgrade":
			SignalBus.emit_signal("ability_toggled", "flame_trail", true, {
				"duration": 8.0,
				"burn_duration": 4.0,
				"burn_damage_multiplier": 20.0
			})
			
		"1_status1": 
			SignalBus.emit_signal("status_effect_applied", "player", "burn_crit_boost", {
				"crit_chance_bonus": 0.20,
				"crit_damage_bonus": 0.20
			})
			
		"1_ability":  
			SignalBus.emit_signal("ability_toggled", "flame_flinger", true, {
				"range": 100,
				"damage": 10,
				"directions": 1
			})
			
		"1_ability_upgrade": 
			SignalBus.emit_signal("ability_toggled", "flame_flinger", true, {
				"range": 100,
				"damage": 20,
				"directions": 1
			})
			
		"1_status2":  
			SignalBus.emit_signal("status_effect_applied", "player", "consecutive_hit_boost", {
				"crit_dmg_per_hit": 0.01,
				"crit_chance_per_hit": 0.01,
				"atk_per_hit": 0.01,
				"reset_window": 0.5
			})
		

		"+10% Movement Speed":
			SignalBus.emit_signal("stat_modified", "player", "movement_speed", 1.10)
			
		"2_trail":  
			SignalBus.emit_signal("ability_toggled", "frost_trail", true, {
				"duration": 5.0,
				"slow_percent": 0.5
			})
			
		"2_trail_upgrade":  
			SignalBus.emit_signal("ability_toggled", "frost_trail", true, {
				"duration": 8.0,
				"slow_percent": 0.9
			})
			
		"2_status1":  
			SignalBus.emit_signal("status_effect_applied", "player", "freeze_on_hit", {
				"freeze_chance": 0.15
			})
			
		"2_ability":  
			SignalBus.emit_signal("ability_toggled", "freeze_frame", true, {
				"duration": 4.0,
				"freeze_projectiles": false,
				"unlimited_range": false

			})
			
		"2_ability_upgrade":  
			SignalBus.emit_signal("ability_toggled", "freeze_frame", true, {
				"duration": 8.0,
				"speed_multiplier": 1.5,
				"unlimited_range": true
			})
			
		"2_status2":  
			SignalBus.emit_signal("stat_modified", "enemies", "movement_speed", 0.6)
		
		"+10% Health":
			SignalBus.emit_signal("stat_modified", "player", "max_health", 1.10)
			
		"3_trail":  
			SignalBus.emit_signal("ability_toggled", "ferment_trail", true, {
				"duration": 5.0,
				"lifesteal_enabled": true,
				"atk_siphon_percent" : 0.0
			})
			
		"3_trail_upgrade":  
			SignalBus.emit_signal("ability_toggled", "ferment_trail", true, {
				"duration": 8.0,
				"lifesteal_enabled": true,
				"atk_siphon_percent": 0.2
			})
			
		"3_status1": 
			SignalBus.emit_signal("status_effect_applied", "player", "health_regen", {
				"amount": 10,
				"interval": 10.0
			})
			
		"3_ability":  
			SignalBus.emit_signal("ability_toggled", "fertilized_farm", true, {
				"spawn_duration": 5.0,
				"ally_lifetime": 10.0
			})
			
		"3_ability_upgrade": 
			SignalBus.emit_signal("status_effect_applied", "player", "fertilized_farm_boost", {
				"multiplier": 2.0
			})
			
		"3_status2": 
			SignalBus.emit_signal("status_effect_applied", "player", "recharging_shield", {
				"recharge_time": 10.0
			})
		_:
			print("Skill effect not implemented: ", skill_id)

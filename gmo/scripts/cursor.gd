extends Area2D

var _speed: float
@onready var _warden: Warden = %Warden

func _ready() -> void:
	position = get_global_mouse_position()
	
	body_entered.connect(
		func(body: Node2D):
			if (position - _warden.position).length() < _warden.slice_radius:
				if body is Fruit:
					_deal_slice_damage(body)
	)

func _physics_process(_delta: float) -> void:
	_speed = (position - get_global_mouse_position()).length()
	position = get_global_mouse_position()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		monitoring = true
	elif Input.is_action_just_released("left_click"):
		monitoring = false

func _deal_slice_damage(enemy: Fruit) -> void:
	"""Calculate damage using Warden's multipliers and SliceDamage system"""
	
	print("\n>>> CURSOR DEALING DAMAGE <<<")
	print("Speed: ", _speed)
	print("Warden attack_damage_multiplier: ", _warden.attack_damage_multiplier)
	
	# Use SliceDamage system with Warden's multiplier
	var damage = SliceDamage.calculate_damage(_speed, _warden.attack_damage_multiplier)
	
	print("Base damage from SliceDamage: ", damage)
	
	# Apply consecutive hit boost if active
	if _warden.consecutive_hit_boost_active and _warden.consecutive_hits > 0:
		var atk_bonus = _warden.consecutive_hits * _warden.consecutive_hit_params.get("atk_per_hit", 0.01)
		damage *= (1.0 + atk_bonus)
		print("After consecutive bonus: ", damage)
	
	# Check for crit
	var target_is_burned = enemy.is_burned
	var crit_stats = _warden.get_crit_stats(target_is_burned)
	
	if randf() < crit_stats.chance:
		damage *= crit_stats.damage
		print("CRITICAL HIT! Damage: ", damage)
	
	print("Final damage: ", damage)
	print(">>> APPLYING DAMAGE <<<\n")
	
	# Apply damage
	enemy.apply_damage(damage, self, 0)
	
	# Track successful hit for bonuses
	_warden.on_successful_hit(enemy)

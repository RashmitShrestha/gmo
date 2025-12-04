extends Area2D

@export var max_damage := 100.0
@export var min_damage := 20.0
@export var max_range := 300.0
@export var cone_angle := 45.0
@export var gravity_strength := 100.0
@export var damage_cooldown := 0.2

var particle: CPUParticles2D
var is_active := false
var player: Node2D
var damaged_enemies := {}

func _ready():
	monitoring = false
	monitorable = false
	
	player = get_parent()
	particle = player.get_node_or_null("FlameFlingerParticle")
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if particle:
		particle.emitting = false
	

func _process(_delta):
	if not is_active:
		return
	
	global_position = player.global_position
	
	if player.last_facing_direction.length() > 0:
		rotation = player.last_facing_direction.angle()
		
		if particle:
			particle.global_position = player.global_position
			particle.rotation = rotation
			
			particle.gravity = Vector2(
				player.last_facing_direction.x * gravity_strength,
				player.last_facing_direction.y * gravity_strength
			)
	else:
		if particle:
			particle.global_position = player.global_position

func toggle():
	is_active = !is_active
	
	if is_active:
		activate()
	else:
		deactivate()

func activate():
	global_position = player.global_position
	rotation = player.last_facing_direction.angle()
	
	particle.global_position = player.global_position
	particle.rotation = rotation
	
	particle.gravity = Vector2(
		player.last_facing_direction.x * gravity_strength,
		player.last_facing_direction.y * gravity_strength
	)
	
	particle.initial_velocity_min = 100.0
	particle.initial_velocity_max = 200.0
	particle.spread = 30.0
	
	monitoring = true
	particle.emitting = true
	particle.restart()
	
	damaged_enemies.clear()
	
func deactivate():
	is_active = false
	particle.emitting = false
	monitoring = false
	damaged_enemies.clear()

func _on_body_entered(body: Node2D):
	if not is_active:
		return
	
	if not body is Fruit:
		return
	
	damaged_enemies[body] = 0.0

func _on_body_exited(body: Node2D):
	if body in damaged_enemies:
		damaged_enemies.erase(body)

func _physics_process(_delta):
	if not is_active:
		return
	
	var curr_time = Time.get_ticks_msec() / 1000.0
	
	for enemy in damaged_enemies.keys():
		if not is_instance_valid(enemy):
			damaged_enemies.erase(enemy)
			continue
		
		if curr_time - damaged_enemies[enemy] < damage_cooldown:
			continue
		
		var to_enemy = enemy.global_position - player.global_position
		var distance = to_enemy.length()
		
		var angle_to_enemy = player.last_facing_direction.angle_to(to_enemy)
		var angle_degrees = abs(rad_to_deg(angle_to_enemy))
		
		if angle_degrees > cone_angle:
			continue
			
		if distance > max_range:
			continue
		
		var damage_ratio = 1.0 - clamp(distance / max_range, 0.0, 1.0)
		var damage = lerp(min_damage, max_damage, damage_ratio)
		
		if enemy.has_method("apply_damage"):
			enemy.apply_damage(damage, self)
		
		damaged_enemies[enemy] = curr_time

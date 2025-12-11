class_name StrawberryShootCommand
extends Command

var _projectile: PackedScene
var _projectile_speed: float
var _frequency: float
var _timer: Timer

func _init(projectile: PackedScene, projectile_speed: float, frequency: float) -> void:
	_projectile = projectile
	_projectile_speed = projectile_speed
	_frequency = frequency


func _shoot(character: Strawberry):
	if not is_instance_valid(character.target):
		return
	
	var dir: Vector2 = (character.target.position - character.position).normalized()
	var seed_projectile: Seed = _projectile.instantiate()
	seed_projectile.position = character.position
	seed_projectile.linear_velocity = dir * _projectile_speed
	seed_projectile.rotation = dir.angle()
	character.get_tree().root.add_child(seed_projectile)


func execute(character: Strawberry) -> Status:
	if _timer == null:
		character.is_attacking = true
		_timer = Timer.new()
		character.add_child(_timer)
		_timer.start(_frequency)
		character.velocity = Vector2.ZERO
		
		_timer.timeout.connect(func(): _shoot(character))
	elif not is_instance_valid(character.target) or \
		character.target.position.distance_to(character.position) <= character.min_dist or \
		character.target.position.distance_to(character.position) >= character.max_dist:
		_timer.queue_free()
		character.is_attacking = false
		return Command.Status.DONE

	return Command.Status.ACTIVE
	

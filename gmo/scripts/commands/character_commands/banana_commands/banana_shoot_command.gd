class_name BananaShootCommand
extends Command

var _projectile: PackedScene
var _projectile_speed: float
var _frequency: float
var _timer: Timer

func _init(projectile: PackedScene, projectile_speed: float, frequency: float) -> void:
	_projectile = projectile
	_projectile_speed = projectile_speed
	_frequency = frequency


func _shoot(character: Banana):
	var dir: Vector2 = (character.target.position - character.position).normalized()
	var seed_projectile: AOESeed = _projectile.instantiate()
	seed_projectile.spawner = character
	seed_projectile.position = character.position
	seed_projectile.linear_velocity = dir * _projectile_speed
	seed_projectile.angular_velocity = 50.0
	character.get_tree().root.add_child(seed_projectile)


func execute(character: Banana) -> Status:
	if _timer == null:
		_timer = Timer.new()
		_timer.one_shot = true
		character.add_child(_timer)
		_timer.start(_frequency)
		character.velocity = Vector2.ZERO
		
		_timer.timeout.connect(
			func(): 
				character.is_attacking = true
				_shoot(character)
		)
	elif _timer.is_stopped():
		_timer.queue_free()
		character.is_attacking = false
		return Command.Status.DONE

	return Command.Status.ACTIVE
	

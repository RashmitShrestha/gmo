class_name PomegranateShootingCommand
extends Command

var _projectile: PackedScene
var _projectile_speed: float
var _timer: Timer
var _finished: bool = false

func _init(projectile: PackedScene, projectile_speed: float) -> void:
	_projectile = projectile
	_projectile_speed = projectile_speed


func _shoot(character: Pomegranate):
	character.velocity = -200 * character.direction
	character.is_attacking = true
	
	for i in range(5):
		if not is_instance_valid(character.target):
			break

		var dir: Vector2 = (character.target.position - character.position).normalized()
		var seed_projectile: Seed = _projectile.instantiate()
		seed_projectile.position = character.position
		seed_projectile.linear_velocity = (dir * _projectile_speed).rotated(randf_range(-0.2, 0.2))
		seed_projectile.rotation = dir.angle()
		character.get_tree().root.add_child(seed_projectile)
		
		await character.get_tree().create_timer(0.1).timeout
	
	character.velocity = Vector2.ZERO


func execute(character: Pomegranate) -> Status:
	if _timer == null:
		_timer = Timer.new()
		_timer.one_shot = true
		character.add_child(_timer)
		_timer.start(1)
		character.velocity = Vector2.ZERO
		
		_timer.timeout.connect(func(): _shoot(character))
		character.get_tree().create_timer(2.0).timeout.connect(
			func():
				_finished = true
		)
	elif _finished:
		_timer.queue_free()
		character.is_attacking = false
		_finished = false
		return Command.Status.DONE
	
	return Command.Status.ACTIVE
	

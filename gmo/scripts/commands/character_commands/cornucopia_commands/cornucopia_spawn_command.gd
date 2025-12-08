class_name CornucopiaSpawnCommand
extends Command

var _timer: Timer
var _spawn_timer: Timer
var _fruits: Array[PackedScene]

func _init():
	_fruits.append(preload("res://scenes/characters/banana.tscn"))
	_fruits.append(preload("res://scenes/characters/blueberry.tscn"))
	_fruits.append(preload("res://scenes/characters/grape.tscn"))
	_fruits.append(preload("res://scenes/characters/pomegranate.tscn"))
	_fruits.append(preload("res://scenes/characters/strawberry.tscn"))
	_fruits.append(preload("res://scenes/characters/watermelon.tscn"))


func _spawn(character: Cornucopia) -> void:
	var choice: int
	var random: float = randf()
				
	if random < 0.25:
		choice = 1
	elif random < 0.5:
		choice = 4
	elif random < 0.65:
		choice = 2
	elif random < 0.8:
		choice = 0
	elif random < 0.9:
		choice = 5
	else:
		choice = 3
				
	var fruit: Fruit = _fruits[choice].instantiate()
	fruit.position = character.position
	character.get_parent().add_child(fruit)

func execute(character: Cornucopia) -> Status:
	if _timer == null:
		_timer = Timer.new()
		_spawn_timer = Timer.new()
		_timer.one_shot = true
		character.add_child(_timer)
		character.add_child(_spawn_timer)
		_timer.start(10.0)
		_spawn_timer.start(1.25)
		
		_spawn_timer.timeout.connect(func(): _spawn(character))
		
	if not _timer.is_stopped():
		var dir: Vector2 = (character.position - character.peach_tree.position).normalized()
		character.velocity = 2 * character.speed * dir.rotated(PI / 2)
		return Command.Status.ACTIVE
	else:
		character.velocity = Vector2.ZERO
		_spawn_timer.queue_free()
		_timer.queue_free()
		return Command.Status.DONE

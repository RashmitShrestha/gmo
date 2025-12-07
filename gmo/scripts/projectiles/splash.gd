class_name Splash
extends Sprite2D

@export var duration: float
@export var area: Area2D
@export var heal_amount: float
@export var damage_amount: float

func _ready() -> void:
	$AnimationPlayer.play("splash")
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.start(duration)
	timer.timeout.connect(func(): queue_free())


func _physics_process(_delta: float) -> void:
	if not area.monitoring: return
	
	for body in area.get_overlapping_bodies():
		if body is Warden or body is PeachTree:
			var game_character := body as GameCharacter
			game_character.apply_damage(damage_amount, self)
		else:
			var game_character := body as GameCharacter
			game_character.heal(heal_amount)

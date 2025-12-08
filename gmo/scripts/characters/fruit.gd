class_name Fruit 
extends GameCharacter

var element : int 
var stun_time: float = 1.0
var warden: Warden
var peach_tree: PeachTree
var target: GameCharacter
var stunned: bool = false
var dead: bool = false
var is_attacking: bool = false
var fertilized : bool = false

var global_slow_modifier: float = 1.0
var frost_trail_modifier: float = 1.0
var frost_timer : Timer

var is_burned: bool = false
var burn_timer: Timer
var stun_timer: Timer

@onready var animation_tree: AnimationTree = $AnimationTree

func _physics_process(_delta: float) -> void:
	if stunned or dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var speed_mult = global_slow_modifier * frost_trail_modifier
	
	if speed_mult != 1.0:
		velocity *= speed_mult
		
	super._physics_process(_delta)
	
	if speed_mult != 1.0:
		velocity /= speed_mult
		
	if dead:
		return
	
	_face_warden()

func _ready():
	add_to_group("enemies")
	super._ready()
		
	SignalBus.player_died.connect(func(): target = peach_tree)
	SignalBus.stat_modified.connect(_on_stat_modified)
	
	animation_tree.active = true
	animation_player.animation_finished.connect(_on_death)
	
	if warden == null:
		warden = get_node_or_null("%Warden")
		if warden == null:
			warden = get_parent().get_node_or_null("Warden") if get_parent() else null
	if peach_tree == null:
		peach_tree = get_node_or_null("%PeachTree")
		if peach_tree == null:
			peach_tree = get_parent().get_node_or_null("PeachTree") if get_parent() else null
	
	target = peach_tree
	
	SignalBus.damage_enemy.connect(_on_damage_enemy)


func _on_damage_enemy(character: GameCharacter, damage: float, element_type: int = 0):
	if character == self:
		apply_damage(damage, self, element_type)


func apply_damage(damage: float, _source: Node2D, elem: int = 0, is_dot: bool = false):
	super(damage, _source, elem, is_dot)
	
	if curr_health <= 0.0 and not dead:
		dead = true
		animation_tree.active = false
		animation_player.play("death")

func _on_death(animation_name: StringName):
	if animation_name == "death":
		_die()

func _face_warden() -> void:
	var direction_to_warden: float = target.global_position.x - global_position.x
	
	if direction_to_warden < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
func _on_stat_modified(character_group: String, stat_name: String, value: float) -> void:
	if character_group != "enemies":
		return
	
	match stat_name:
		"movement_speed":
			global_slow_modifier *= value

func enter_frost_trail(slow_percent: float, duration: float = 5.0) -> void:	
	if is_instance_valid(frost_timer):
		frost_timer.queue_free()
	
	frost_trail_modifier = 1.0 - slow_percent
	
	
	frost_timer = Timer.new()
	frost_timer.wait_time = duration
	frost_timer.one_shot = true
	add_child(frost_timer)
	
	frost_timer.timeout.connect(
		func():
			frost_trail_modifier = 1.0
			if is_instance_valid(frost_timer):
				frost_timer.queue_free()
	)
	frost_timer.start()

func apply_burn(duration: float, _damage_multiplier: float = 1.0) -> void:
	is_burned = true
	
	if is_instance_valid(burn_timer):
		burn_timer.queue_free()
	
	burn_timer = Timer.new()
	burn_timer.wait_time = duration
	burn_timer.one_shot = true
	add_child(burn_timer)
	
	burn_timer.timeout.connect(
		func():
			is_burned = false
			if is_instance_valid(burn_timer):
				burn_timer.queue_free()
	)
	burn_timer.start()	

func apply_stun() -> void:	
	if is_instance_valid(stun_timer):
		stun_timer.queue_free()
	
	stunned = true
	
	stun_timer = Timer.new()
	stun_timer.wait_time = stun_time
	stun_timer.one_shot = true
	add_child(stun_timer)
	
	stun_timer.timeout.connect(
		func():
			stunned = false
			if is_instance_valid(stun_timer):
				stun_timer.queue_free()
	)
	stun_timer.start()

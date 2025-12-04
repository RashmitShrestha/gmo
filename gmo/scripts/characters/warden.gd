class_name Warden
extends GameCharacter

@export var dash_speed_curve: Curve
@export var knockback_speed_curve: Curve
@export var dash_invulnerability_duration: float
@export var invulnerability_duration: float

@export var command_manager_component: PlayerCommandManagerComponent
@export var input_component: PlayerInputComponent
@export var animation_manager_component: PlayerAnimationManagerComponent
@export var slice_radius = 300

@onready var animation_tree: AnimationTree = $AnimationTree
var last_facing_direction := Vector2.RIGHT  

var _invulnerability_timer: Timer
var _blink_timer: Timer

var curr_command: Command
var idle_command: PlayerIdleCommand
var move_command: PlayerMoveCommand
var dash_command: PlayerDashCommand
var knockback_command: PlayerKnockbackCommand

var vel_vec := Vector2.ZERO
var curr_vel: int = 0
var is_slicing: bool = false

# cooldown of the 6 total abilities 
var cd1 : float
var cd2 : float
var cd3 : float
var cd4 : float
var cd5 : float
var cd6 : float

func _ready() -> void:
	max_health = 100.0  # Initialize player health
	curr_health = max_health
	animation_tree.active = true
	idle_command = PlayerIdleCommand.new()
	move_command = PlayerMoveCommand.new()
	dash_command = PlayerDashCommand.new(dash_speed_curve)
	knockback_command = PlayerKnockbackCommand.new(knockback_speed_curve, self)
	
	received_damage.connect(
		func(damage: float, _source: Node2D):
			SignalBus.player_health_changed.emit(curr_health - damage, max_health)
			hurt_animation()
			make_invulnerable(invulnerability_duration)
			curr_health -= damage
	)
	
	queue_redraw()  # Add this


func _input(event):
	input_component.update(event)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()


func make_invulnerable(duration: float) -> void:
	invulnerable = true
	
	_invulnerability_timer = Timer.new()
	_invulnerability_timer.one_shot = true

	add_child(_invulnerability_timer)
	
	_invulnerability_timer.timeout.connect(
		func():
			invulnerable = false
			_invulnerability_timer.queue_free()
	)

	_invulnerability_timer.start(duration)
	
func hurt_animation():
	_blink_timer = Timer.new()
	add_child(_blink_timer)
	
	_blink_timer.timeout.connect(
		func():
			sprite.visible = not sprite.visible
	)
	
	_blink_timer.start(0.06)
	get_tree().create_timer(invulnerability_duration).timeout.connect(
		func():
			_blink_timer.queue_free()
			sprite.visible = true
	)
	
	sprite.self_modulate = Color(1.0, 0.117, 0.419, 0.5)
	await get_tree().create_timer(.5).timeout
	sprite.self_modulate = Color(1,1,1,1)
	#for anim in range(4):
	
	damaged = false

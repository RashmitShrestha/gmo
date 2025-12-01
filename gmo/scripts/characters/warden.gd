class_name Warden
extends GameCharacter

@export var dash_speed_curve: Curve
@export var invulnerability_duration: float

@export var command_manager_component: PlayerCommandManagerComponent
@export var input_component: PlayerInputComponent
@export var animation_manager_component: PlayerAnimationManagerComponent

@onready var animation_tree: AnimationTree = $AnimationTree

var _invulnerability_timer: Timer
var _blink_timer: Timer

var curr_command: Command
var idle_command: PlayerIdleCommand
var move_command: PlayerMoveCommand
var dash_command: PlayerDashCommand

var vel_vec := Vector2.ZERO
var curr_vel: int = 0
var is_slicing: bool = false

var slice_radius = 300

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
	
	received_damage.connect(
		func(damage, _source):
			SignalBus.player_health_changed.emit(curr_health - damage, max_health)
			make_invulnerable()
			curr_health -= damage
	)
	
	queue_redraw()  # Add this


func _input(event):
	input_component.update(event)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()


func make_invulnerable() -> void:
	invulnerable = true
	
	_invulnerability_timer = Timer.new()
	_blink_timer = Timer.new()
	_invulnerability_timer.one_shot = true

	add_child(_invulnerability_timer)
	add_child(_blink_timer)
	
	_invulnerability_timer.timeout.connect(
		func(): 
			_blink_timer.queue_free()
			sprite.visible = true
			invulnerable = false
			_invulnerability_timer.queue_free()
	)
	_blink_timer.timeout.connect(
		func():
			sprite.visible = not sprite.visible
	)

	_invulnerability_timer.start(invulnerability_duration)
	_blink_timer.start(0.06)

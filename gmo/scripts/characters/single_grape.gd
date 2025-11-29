class_name SingleGrape
extends GameCharacter

@export var stun_time: float = 1.0
@export var animation_manager_component: SingleGrapeAnimationManagerComponent
@export var command_manager_component: SingleGrapeCommandManagerComponent
@export var reactive_component: SingleGrapeReactiveComponent

var warden: Warden
var full_slash = 1
var stunned: bool = false
var curr_command: Command
var default_command: SingleGrapeDefaultCommand
var stun_command: SingleGrapeStunCommand

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	health = 100 * full_slash  # 100 HP (1 full slash)
	
	animation_tree.active = true
	warden = %Warden
	
	default_command = SingleGrapeDefaultCommand.new(speed)
	stun_command = SingleGrapeStunCommand.new(stun_time)
	
	SignalBus.damage_enemy.connect(_on_damage_enemy)
	$Area2D.connect("mouse_entered", _on_mouse_entered)

func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)

func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()

func _on_mouse_entered():
	if warden and warden.is_slicing:
		SignalBus.damage_enemy.emit(self, warden.curr_vel)

func _on_damage_enemy(character: GameCharacter, slice_velocity: float):
	if character == self:
		var damage = SliceDamage.calculate_damage(slice_velocity)
		health -= damage
		
		print(str(self) + " took " + str(damage) + " damage. Health: " + str(health))
		
		if health <= 0:
			_die()

func _die():
	print(str(self) + " has been defeated!")
	
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	
	queue_free()

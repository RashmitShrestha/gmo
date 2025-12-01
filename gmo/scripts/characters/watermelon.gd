class_name Watermelon
extends GameCharacter

@export var step_time: float = 0.2
@export var stun_time: float = 1.0
@export var animation_manager_component: WatermelonAnimationManagerComponent
@export var command_manager_component: WatermelonCommandManagerComponent
@export var reactive_component: WatermelonReactiveComponent
@export var damage_component: WatermelonDamageComponent

var warden: Warden
var full_slash = 45
var stunned: bool = false
var curr_command: Command
var step_command: WatermelonStepCommand
var stun_command: WatermelonStunCommand

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	max_health = 100 * full_slash  # 1000 HP
	curr_health = max_health
	
	animation_tree.active = true
	warden = %Warden
	
	step_command = WatermelonStepCommand.new(speed, step_time)
	stun_command = WatermelonStunCommand.new(stun_time)
	
	SignalBus.damage_enemy.connect(_on_damage_enemy)
	$Area2D.connect("mouse_entered", _on_mouse_entered)

func _physics_process(_delta) -> void:
	reactive_component.update()
	damage_component.update()
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
		curr_health -= damage
		
		print(str(self) + " took " + str(damage) + " damage. Health: " + str(curr_health))
		
		if curr_health <= 0:
			_die()

func _die():
	print(str(self) + " has been defeated!")
	
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	
	queue_free()

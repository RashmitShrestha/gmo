class_name Grape
extends GameCharacter

@export var stun_time: float = 1.0
@export var animation_manager_component: GrapeAnimationManagerComponent
@export var command_manager_component: GrapeCommandManagerComponent
@export var reactive_component: GrapeReactiveComponent

var warden: Warden
var full_slash = 20
var stunned: bool = false
var curr_command: Command
var default_command: GrapeDefaultCommand
var stun_command: GrapeStunCommand

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	max_health = 100 * full_slash  # Total health = 2000
	curr_health = max_health
	
	animation_tree.active = true
	warden = %Warden
	
	default_command = GrapeDefaultCommand.new(speed)
	stun_command = GrapeStunCommand.new(stun_time)
	
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
		# Calculate damage using SliceDamage utility
		var damage = SliceDamage.calculate_damage(slice_velocity)
		
		# Apply damage
		curr_health -= damage
		
		print(str(self) + " took " + str(damage) + " damage. Health: " + str(curr_health))
		
		# Check if dead
		if curr_health <= 0:
			_die()

func _die():
	print(str(self) + " has been defeated!")
	
	# Hide the grape
	visible = false
	
	# Disable collisions so it doesn't interact anymore
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	
	# Optional: Play death animation/particles before removing
	# await get_tree().create_timer(0.5).timeout
	
	# Remove from scene tree
	queue_free()

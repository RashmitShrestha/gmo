class_name Grape
extends Fruit

@export var animation_manager_component: GrapeAnimationManagerComponent
@export var command_manager_component: GrapeCommandManagerComponent
@export var reactive_component: GrapeReactiveComponent
@export var knockback_curve: Curve

var full_slash = 20
var curr_command: Command
var default_command: GrapeDefaultCommand
var stun_command: GrapeStunCommand
var knockback_command: KnockbackCommand

func _ready():
	super()
	
	default_command = GrapeDefaultCommand.new(speed)
	stun_command = GrapeStunCommand.new(stun_time)
	knockback_command = KnockbackCommand.new(knockback_curve, self)


func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)

func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()


'''
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

'''

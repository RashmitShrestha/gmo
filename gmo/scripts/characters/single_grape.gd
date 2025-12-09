class_name SingleGrape
extends Fruit

@export var animation_manager_component: SingleGrapeAnimationManagerComponent
@export var command_manager_component: SingleGrapeCommandManagerComponent
@export var reactive_component: SingleGrapeReactiveComponent
@export var knockback_curve: Curve

var full_slash = 1
var curr_command: Command
var default_command: SingleGrapeDefaultCommand
var stun_command: SingleGrapeStunCommand
var knockback_command: KnockbackCommand


func _ready():
	super()
	
	default_command = SingleGrapeDefaultCommand.new(speed)
	stun_command = SingleGrapeStunCommand.new(stun_time)
	knockback_command = KnockbackCommand.new(knockback_curve, self)
	

func _physics_process(_delta) -> void:
	reactive_component.update()
	super(_delta)


func _process(_delta) -> void:
	command_manager_component.update()
	animation_manager_component.update()
	

func _die():
	print(str(self) + " has been defeated!")

	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)

	super()

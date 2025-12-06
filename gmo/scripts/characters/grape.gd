class_name Grape
extends Fruit

@export var animation_manager_component: GrapeAnimationManagerComponent
@export var command_manager_component: GrapeCommandManagerComponent
@export var reactive_component: GrapeReactiveComponent
@export var knockback_curve: Curve

@onready var single_grape: PackedScene = preload("res://scenes/characters/single_grape.tscn")

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


func _die():
	var g1: SingleGrape = single_grape.instantiate()
	var g2: SingleGrape = single_grape.instantiate()
	var g3: SingleGrape = single_grape.instantiate()
	
	g1.position = position + Vector2(50.0, 0)
	g2.position = position + Vector2(-25.0, 43.3)
	g3.position = position + Vector2(-25.0, -43.3)
	
	get_parent().add_child(g1)
	get_parent().add_child(g2)
	get_parent().add_child(g3)
	
	super()

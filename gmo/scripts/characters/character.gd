class_name GameCharacter
extends CharacterBody2D

@export var speed: float
var direction := Vector2.ZERO


func _physics_process(_delta: float) -> void:
	move_and_slide()

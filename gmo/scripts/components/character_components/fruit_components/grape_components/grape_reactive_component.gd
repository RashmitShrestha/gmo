class_name GrapeReactiveComponent
extends ReactiveComponent

func _ready():
	super()
	_parent.mouse_entered.connect(_on_mouse_entered)
	_parent.mouse_exited.connect(_on_mouse_exited)


func update():
	_parent.direction = (_parent.target.global_position - _parent.global_position).normalized()
	
	if _parent.get_slide_collision_count():
		_parent.stunned = true


func _on_mouse_entered():
	print("entered grape")


func _on_mouse_exited():
	print("exited grape")

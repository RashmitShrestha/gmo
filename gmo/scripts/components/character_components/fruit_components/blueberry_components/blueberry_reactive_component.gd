class_name BlueberryReactiveComponent
extends ReactiveComponent

func _ready():
	super()
	var area = _parent.get_node_or_null("Area2D")
	if area:
		area.mouse_entered.connect(_on_mouse_entered)
		area.mouse_exited.connect(_on_mouse_exited)
		area.input_pickable = true

func update():
	# Check if target is valid before accessing it
	if not is_instance_valid(_parent.target):
		return

	_parent.direction = (_parent.target.global_position - _parent.global_position).normalized()
	
	if _parent.get_slide_collision_count():
		_parent.stunned = true

func _on_mouse_entered():
	print("entered blueberry")

func _on_mouse_exited():
	print("exited blueberry")

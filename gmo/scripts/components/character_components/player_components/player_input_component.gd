class_name PlayerInputComponent
extends InputComponent

func update(event: InputEvent) -> void:
	_parent.direction = Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	).normalized()
	
	var slice = _parent.get_node("Slice")
	var mouse_pos = _parent.get_global_mouse_position()
	
	# pressing the number keys 1, 2, or 3 will set the element
	# checks if current element is not a element
	if Input.is_action_just_pressed("special_1") and slice.current_element < 0:
		slice.set_element(1)
		
	elif Input.is_action_just_pressed("special_2") and slice.current_element < 0:
		slice.set_element(2)
		
	elif Input.is_action_just_pressed("special_3") and slice.current_element < 0:
		slice.set_element(3)
	
	# Handle slicing/drawing
	if Input.is_action_pressed("left_click"):
		if event is InputEventMouseMotion:
			# If we have an element ready and haven't started slicing yet, activate it
			if slice.element_ready >= 0 and slice.current_element < 0:
				slice.start_trail(slice.element_ready)
			
			# update the parents values as intended for slicing
			_parent.is_slicing = true
			_parent.vel_vec = event.relative
			_parent.curr_vel = abs(Vector2.ZERO.distance_to(_parent.vel_vec))
			
			slice.slicing(mouse_pos)
	else:
		_parent.is_slicing = false
		
		# if we were using an element, end the slice
		if slice.current_element >= 0:
			slice.end_trail()
		
		# clear poitns when not slicing
		slice.clear_points()
		slice.points_queue = []

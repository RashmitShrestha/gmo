class_name PlayerInputComponent
extends InputComponent

# _parent refers to warden.gd
func update(event: InputEvent) -> void:
	_parent.direction = Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	).normalized()
	
	var slice = _parent.get_node("Slice")
	var slice_particle = slice.get_node("../SliceParticle")
	var mouse_pos = _parent.get_global_mouse_position()
	
	# pressing the number keys 1, 2, or 3 will set the element
	if Input.is_action_just_pressed("special_1") and slice.current_element < 0:
		slice.set_element(1)
		
	elif Input.is_action_just_pressed("special_2") and slice.current_element < 0:
		slice.set_element(2)
		
	elif Input.is_action_just_pressed("special_3") and slice.current_element < 0:
		slice.set_element(3)
		
	elif Input.is_action_just_pressed("special_4"):
		var flame_flinger = _parent.get_node_or_null("FlameFlingerArea")
		flame_flinger.toggle()
			
	#elif Input.is_action_just_pressed("special_5"):
#
	#elif Input.is_action_just_pressed("special_6"):

	
	# Handle slicing/drawing
	if Input.is_action_pressed("left_click") and _parent.global_position.distance_to(mouse_pos) < _parent.slice_radius:
		# If we have an element ready and haven't started slicing yet, activate it
		if slice.element_ready >= 0 and slice.current_element < 0:
			slice.start_trail(slice.element_ready)
		
		if event is InputEventMouseMotion and event.relative.length() > 1:
			# Update parent values
			_parent.is_slicing = true
			_parent.vel_vec = event.relative
			_parent.curr_vel = abs(Vector2.ZERO.distance_to(_parent.vel_vec))
			
			# Always update particle position and emit
			slice_particle.global_position = mouse_pos
			slice_particle.emitting = true
			
			# Only add points to trail if element is active
			if slice.current_element >= 0:
				slice.slicing(mouse_pos)
		else:
			# Not moving, stop particles
			slice_particle.emitting = false
			_parent.is_slicing = false
	else:
		# Mouse released
		_parent.is_slicing = false
		slice_particle.emitting = false
		
		# if we were using an element, end the slice
		if slice.current_element >= 0:
			slice.end_trail()

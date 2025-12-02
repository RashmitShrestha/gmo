class_name ElementSystem
extends Node

# 0 = none
# 1 = flame
# 2 = frozen
# 3 = ferment 

# DAMAGE TYPING
# flame - > ferment
# ferment -> frozen
# frozen -> flame 

# dmg_element - the element type of damage
# health_element - the element type that receives the damage
static func element_mult(dmg_element :int, health_element: int) -> float:
	if not dmg_element or not health_element:
		return 1.0
	else:
		if dmg_element == 1:
			if health_element == 3:
				return 2.0
			elif health_element == 2:
				return 0.5
			else:
				return 1.0
		elif dmg_element == 2:
			if health_element == 1:
				return 2.0
			elif health_element == 3:
				return 0.5
			else:
				return 1.0
		else:
			if health_element == 2:
				return 2.0
			elif health_element == 1:
				return 0.5
			else:
				return 1.0

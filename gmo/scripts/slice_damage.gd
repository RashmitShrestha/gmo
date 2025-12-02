class_name SliceDamage
extends Node

# Calculate damage based on slice velocity
# velocity >= 70 = 100 damage (full slash)
# velocity < 70 = velocity value as damage
static func calculate_damage(velocity: float, mult: float) -> float:
	if velocity >= 70:
		return mult * 100.0
	else:
		return velocity * mult * 100/70

# Alternative: If you want a smoother scaling
# static func calculate_damage_scaled(velocity: float) -> float:
# 	return clamp(velocity, 0, 100)

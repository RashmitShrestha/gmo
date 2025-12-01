class_name WatermelonDamageComponent
extends DamageComponent

func update():
	for i in range(_parent.get_slide_collision_count()):
		var collider: Object = _parent.get_slide_collision(i).get_collider()
		
		if collider is Warden:
			collider.apply_damage(10.0, self)

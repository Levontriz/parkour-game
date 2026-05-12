extends Area2D
class_name Hitbox

@export var health_resource : VitalResource

func take_damage(amount : float):
	if health_resource != null:
		health_resource.subtract(amount)
		print(get_parent().name + " Took Damage")

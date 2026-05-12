extends Area2D
class_name AttackBox

@export var damage = 10.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		area.take_damage(damage)

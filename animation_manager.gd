extends Node
class_name AnimationManager

@export var animated_sprite : AnimatedSprite2D

var current_animation

func playAnimation(animation_name : String):
	if current_animation == animation_name:
		return
	current_animation = animation_name
	animated_sprite.play(animation_name)

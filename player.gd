extends CharacterBody2D

const SPEED = 300.0
const ACCEL = 1500.0
const FRICTION = 1200.0
const JUMP_VELOCITY = -450.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_direction = "right" # Keeps track of facing direction

@onready var anim_tree = $AnimationTree
@onready var playback = anim_tree.get("parameters/playback")
@onready var ground_ray = $RayCast2D

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	# 1. Handle Horizontal Movement & Direction Tracking
	var direction = Input.get_axis("Left", "Right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL * delta)
		last_direction = "right" if direction > 0 else "left"
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# 2. Jump Input
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		playback.travel("jump_" + last_direction + "_start") # Uses direction for jump too

	update_animation_states()
	move_and_slide()

func update_animation_states():
	if is_on_floor():
		if velocity.x != 0:
			playback.travel("walk_" + last_direction) # Plays "walk_left" or "walk_right"
		else:
			playback.travel("still_" + last_direction)
	else:
		# Mid-air/Falling logic
		if velocity.y > 0:
			if ground_ray.is_colliding():
				playback.travel("roll_" + last_direction)
			else:
				playback.travel("jump_mid_" + last_direction)

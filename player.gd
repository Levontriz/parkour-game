extends CharacterBody2D

@export var SPEED = 300.0
@export var ACCEL = 1500.0
@export var FRICTION = 1200.0
@export var JUMP_VELOCITY = -450.0
@export var DASH_VELOCITY = 800.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_jump = true
var can_dash = true
var was_on_floor = false
var was_airborne = false
var horz_direction
var vert_direction

@onready var jump_timer : Timer = $JumpFrames
@onready var animation_tree : AnimationTree = $AnimationTree

func set_anim(condition: String, value: bool) -> void:
	animation_tree.set("parameters/conditions/" + condition, value)

func _physics_process(delta):
	# 1. Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Coyote Time & Floor State
	if is_on_floor():
		can_dash = true
		if not was_on_floor:
			can_jump = true
		was_on_floor = true
	elif was_on_floor:
		jump_timer.start()
		was_on_floor = false

	# 3. Landing Detection
	if was_airborne and is_on_floor():
		set_anim("is_landing", true)
	was_airborne = not is_on_floor()

	# 4. Horizontal Movement
	horz_direction = Input.get_axis("Left", "Right")
	vert_direction = Input.get_axis("Up", "Down")

	if horz_direction != 0:
		velocity.x = move_toward(velocity.x, horz_direction * SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# 5. Animation
	set_anim("is_moving_left",  horz_direction < 0)
	set_anim("is_moving_right", horz_direction > 0)
	set_anim("is_stationary",   is_zero_approx(horz_direction))
	set_anim("is_airborne",     not is_on_floor())

	# 6. Jump
	if Input.is_action_just_pressed("Jump") and can_jump:
		can_jump = false
		velocity.y = JUMP_VELOCITY

	# 7. Dash
	if Input.is_action_just_pressed("Jump") and can_dash and not is_on_floor():
		can_dash = false
		velocity.y += DASH_VELOCITY * vert_direction
		velocity.x += DASH_VELOCITY * horz_direction
		set_anim("is_dashing", true)

	move_and_slide()

func _on_jump_frames_timeout() -> void:
	can_jump = false

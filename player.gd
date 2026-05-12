extends CharacterBody2D

@export var SPEED = 300.0
@export var ACCEL = 1500.0
@export var FRICTION = 1200.0
@export var JUMP_VELOCITY = -450.0
@export var DASH_DISTANCE = 240.0 # Pixels?
@export var DASH_TIME = 0.2 # Seconds
@export var DASH_VELOCITY = DASH_DISTANCE / DASH_TIME

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var can_jump = true

var can_dash = true
var is_dashing = false

var was_on_floor = false
var was_airborne = false

var horz_direction
var vert_direction

@onready var jump_timer : Timer = $JumpFrames
@onready var dash_timer : Timer = $DashLength
@onready var animation_tree : AnimationTree = $AnimationTree

func _ready() -> void:
	dash_timer.wait_time = DASH_TIME

func set_anim(condition: String, value: bool) -> void:
	animation_tree.set("parameters/conditions/" + condition, value)

func _physics_process(delta):
	# 1. Gravity
	if not is_on_floor() and !is_dashing:
		velocity.y += gravity * delta

	# 2. Coyote Time & Floor State
	if is_on_floor():
		can_dash = true
		can_jump = true
	elif was_on_floor:
		jump_timer.start()

	# 3. Landing Detection
	if was_airborne and is_on_floor():
		set_anim("is_landing", true)
	was_airborne = not is_on_floor()

	# 4. Horizontal Movement
	horz_direction = Input.get_axis("Left", "Right")
	vert_direction = Input.get_axis("Up", "Down")

	if horz_direction != 0:
		if is_on_floor():
			# Instant snap to max speed on ground
			velocity.x = horz_direction * SPEED
		else:
			# Smooth acceleration in the air for better control
			velocity.x = move_toward(velocity.x, horz_direction * SPEED, ACCEL * delta)
	elif !is_dashing:
		if is_on_floor():
			# Instant stop on ground (No sliding)
				velocity.x = 0
		else:
			# Air resistance/friction
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


	# 5. Animation
	set_anim("is_moving_left",    horz_direction < 0)
	set_anim("is_moving_right",   horz_direction > 0)
	set_anim("is_stationary",     is_zero_approx(horz_direction))
	set_anim("is_airborne",       not is_on_floor())
	set_anim("is_jumping_right",  (horz_direction > 0) and (not is_on_floor()))
	set_anim("is_grounded_right",  (horz_direction > 0) and is_on_floor())
	set_anim("is_jumping_left",  (horz_direction < 0) and (not is_on_floor()))
	set_anim("is_grounded_left",  (horz_direction < 0) and is_on_floor())
	
	# 6. Jump
	if Input.is_action_just_pressed("Jump") and can_jump:
		can_jump = false
		velocity.y = JUMP_VELOCITY

	# 7. Dash
	elif Input.is_action_just_pressed("Jump") and can_dash and not is_on_floor():
		can_dash = false
		is_dashing = true
		dash_timer.start()
		var dash_dir = Vector2(horz_direction, vert_direction).normalized()
		velocity = dash_dir * DASH_VELOCITY
		set_anim("is_dashing", true)

	move_and_slide()

func _on_jump_frames_timeout() -> void:
	can_jump = false


func _on_dash_length_timeout() -> void:
	is_dashing = false
	# Snap velocity to zero (or a reduced amount) to prevent "flinging"
	velocity = Vector2.ZERO 
	

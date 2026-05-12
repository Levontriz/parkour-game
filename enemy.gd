extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400

var target : CharacterBody2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction = 0
	if target != null:
		var target_dir = global_position.direction_to(target.global_position)
		direction = sign(target_dir.x)
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		target = body
		



func _on_detection_area_body_exited(body: Node2D) -> void:
	target = null

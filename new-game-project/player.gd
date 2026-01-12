extends CharacterBody2D

@export var base_speed := 250.0
@export var base_jump_velocity := -1000.0
@export var base_gravity := 1400.0

@export var world_width := 540.0

# runtime values
var speed := base_speed
var jump_velocity := base_jump_velocity
var gravity := base_gravity

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * speed

	move_and_slide()

	if is_on_floor() and velocity.y >= 0:
		velocity.y = jump_velocity

	# screen wrap (edge-safe)
	var margin := 5.0
	if global_position.x < -margin:
		global_position.x = world_width + margin
	elif global_position.x > world_width + margin:
		global_position.x = -margin

# Called by Main to ramp difficulty
func set_difficulty(multiplier: float):
	speed = base_speed * multiplier
	jump_velocity = base_jump_velocity * multiplier
	gravity = base_gravity * multiplier

extends StaticBody2D

enum PlatformType {
	NORMAL,
	MOVING,
	BREAKABLE,
	BOUNCY
}

@export var platform_type: PlatformType = PlatformType.NORMAL
@export var move_speed := 100.0
@export var move_range := 150.0

var start_x := 0.0
var move_direction := 1
var times_landed := 0
var is_broken := false

@onready var sprite := $CollisionShape2D/Sprite2D
@onready var collision := $CollisionShape2D
@onready var detector_area := $DetectorArea

func _ready():
	start_x = global_position.x
	apply_visual_style()

func _process(delta):
	if platform_type == PlatformType.MOVING and not is_broken:
		# Move back and forth
		global_position.x += move_speed * move_direction * delta
		
		# Reverse direction at boundaries
		if abs(global_position.x - start_x) > move_range:
			move_direction *= -1

func apply_visual_style():
	if sprite == null:
		return
		
	match platform_type:
		PlatformType.NORMAL:
			sprite.modulate = Color.WHITE
		PlatformType.MOVING:
			sprite.modulate = Color.CYAN
		PlatformType.BREAKABLE:
			sprite.modulate = Color.ORANGE_RED
		PlatformType.BOUNCY:
			sprite.modulate = Color.SPRING_GREEN

func _on_body_entered(body):
	if body.name == "Player" and not is_broken:
		print("Platform hit! Type: ", platform_type)
		if platform_type == PlatformType.BOUNCY:
			# high jump boost
			body.velocity.y = body.base_jump_velocity * 2.5
		elif platform_type == PlatformType.BREAKABLE:
			# Break immediately on landing
			print("Breaking platform!")
			break_platform()

func break_platform():
	is_broken = true
	# Disable collision immediately
	collision.disabled = true
	# Fade out 
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	# Delete after animation
	await tween.finished
	queue_free()

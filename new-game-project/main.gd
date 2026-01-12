extends Node2D

@export var platform_scene: PackedScene
@export var world_width := 540.0

# platform spawning
@export var spawn_gap_min := 70.0
@export var spawn_gap_max := 120.0
@export var keep_above_camera := 1400.0
@export var delete_below_camera := 1000.0

# difficulty scaling
@export var difficulty_step := 50        # score per difficulty increase
@export var difficulty_increase := 0.12  # +12% per step
@export var max_difficulty := 3.0        # cap so physics doesn't explode

@onready var player := $Player
@onready var cam := $Camera2D
@onready var platforms := $Platforms
@onready var score_label := $CanvasLayer/ScoreLabel

var start_y := 0.0
var highest_y := 0.0
var score := 0

func _ready():
	start_y = player.global_position.y
	reset_game()

func _process(_delta):
	# camera follows upward only
	if player.global_position.y < cam.global_position.y:
		cam.global_position.y = player.global_position.y

	update_score()
	spawn_platforms_if_needed()
	cleanup_platforms()

	# game over ONLY if truly below camera
	if player.global_position.y - cam.global_position.y > delete_below_camera:
		reset_game()

# -------------------------
# SCORE + DIFFICULTY
# -------------------------

func update_score():
	var height: float = start_y - player.global_position.y
	var new_score := int(height / 10.0)

	if new_score > score:
		score = new_score
		score_label.text = "Score: %d" % score
		update_difficulty()

func update_difficulty():
	var steps := score / difficulty_step
	var multiplier := 1.0 + steps * difficulty_increase
	multiplier = min(multiplier, max_difficulty)

	player.set_difficulty(multiplier)

# -------------------------
# PLATFORM LOGIC
# -------------------------

func spawn_platform_at(pos: Vector2):
	var plat = platform_scene.instantiate()
	platforms.add_child(plat)
	plat.global_position = pos
	return plat

func spawn_platforms_if_needed():
	while highest_y > cam.global_position.y - keep_above_camera:
		var gap := randf_range(spawn_gap_min, spawn_gap_max)
		highest_y -= gap

		var x := randf_range(40.0, world_width - 40.0)
		spawn_platform_at(Vector2(x, highest_y))

func cleanup_platforms():
	for p in platforms.get_children():
		if p.global_position.y > cam.global_position.y + delete_below_camera:
			p.queue_free()

# -------------------------
# RESET / START
# -------------------------

func reset_game():
	# clear platforms
	for p in platforms.get_children():
		p.queue_free()

	# reset score
	score = 0
	score_label.text = "Score: 0"

	# reset player safely (centered)
	player.global_position = Vector2(
		world_width * 0.5,
		start_y
	)
	player.velocity = Vector2.ZERO
	player.set_difficulty(1.0)

	# reset camera
	cam.global_position.y = start_y

	# spawn guaranteed starting platform
	var start_platform_offset := 40.0
	var start_platform_pos := Vector2(
		player.global_position.x,
		player.global_position.y + start_platform_offset
	)

	spawn_platform_at(start_platform_pos)

	# initialize spawn height
	highest_y = start_platform_pos.y

	# spawn initial platforms above
	for i in range(10):
		var gap := randf_range(spawn_gap_min, spawn_gap_max)
		highest_y -= gap
		var x := randf_range(40.0, world_width - 40.0)
		spawn_platform_at(Vector2(x, highest_y))

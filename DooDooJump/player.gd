extends CharacterBody2D

@export var base_speed := 250.0
@export var base_jump_velocity := -1000.0
@export var base_gravity := 1400.0

@export var world_width := 540.0

# runtime values
var speed := base_speed
var jump_velocity := base_jump_velocity
var gravity := base_gravity

# tracking variables
var player_id := ""
var starting_multiplier := 1.0
var csv_file_path := "res://player_data.csv"
var start_time := 0.0
var time_alive := 0.0

func _ready():
	# random player ID
	randomize()
	player_id = generate_player_id()
	
	# Start timer
	start_time = Time.get_ticks_msec() / 1000.0
	
	# 50/50 chance to start with high or low speed
	if randf() < 0.5:
		# Low speed start
		starting_multiplier = 1.0
		set_difficulty(starting_multiplier)
		print("Starting with LOW speed (1.0x)")
	else:
		# High speed start
		starting_multiplier = 5.0
		set_difficulty(starting_multiplier)
		print("Starting with HIGH speed (5.0x)")

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

# Called by Main to increase difficulty
func set_difficulty(multiplier: float):
	speed = base_speed * multiplier
	jump_velocity = base_jump_velocity * multiplier
	gravity = base_gravity * multiplier

# Generate a random player ID
func generate_player_id() -> String:
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var id = "P"
	for i in range(8):
		id += chars[randi() % chars.length()]
	return id

# Save player data to CSV (called when player dies)
func save_to_csv():
	# Calculate time alive
	time_alive = (Time.get_ticks_msec() / 1000.0) - start_time
	
	# Get the actual file path
	var actual_path = ProjectSettings.globalize_path(csv_file_path)
	
	var file: FileAccess
	
	# Check if file exists to determine if we need headers
	var file_exists = FileAccess.file_exists(csv_file_path)
	
	# Open file - use WRITE mode to create if doesn't exist, READ_WRITE if it does
	if file_exists:
		file = FileAccess.open(csv_file_path, FileAccess.READ_WRITE)
	else:
		file = FileAccess.open(csv_file_path, FileAccess.WRITE)
	
	if file == null:
		print("Error opening CSV file: ", FileAccess.get_open_error())
		return
	
	# If new file, write header
	if not file_exists:
		file.store_line("PlayerID,SpeedMultiplier,TimeAlive,Timestamp")
	else:
		# Move to end of file for existing file
		file.seek_end()
	
	# Write data
	var timestamp = Time.get_datetime_string_from_system()
	var line = "%s,%.1f,%.2f,%s" % [player_id, starting_multiplier, time_alive, timestamp]
	file.store_line(line)
	file.close()
	
	print("Player ID: %s | Speed: %.1fx | Time Alive: %.2fs" % [player_id, starting_multiplier, time_alive])
	print("CSV saved to: %s" % actual_path)

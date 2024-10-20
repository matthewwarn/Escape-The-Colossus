extends Node2D

# Signals connected to the game manager to control level loading.
signal level_reset_requested;
signal level_requested(level_path: String);
signal main_menu_requested;
signal request_save;

const SMOOTHING_SPEED: int = 15;

@onready var pause_menu_popup: Window = $PauseMenuPopup
@onready var player: CharacterBody2D = $Player
@onready var end_locator: Node2D = $EndLocator
@onready var camera: Camera2D = $Player/Camera2D

## Paths to adjacent game levels.
## Give paths relative to res://Scenes/Levels and include .tscn
@export
var previous_level: String;
@export
var exit_a: String;
@export
var exit_b: String;
@export
var level_music : AudioStream;

func _ready() -> void:
	camera.position_smoothing_enabled = SettingsManager.camera_smoothing;
	camera.position_smoothing_speed = SMOOTHING_SPEED;
	player.double_jump_toggle = Abilities.double_jump_enabled;
	player.dash_toggle = Abilities.dash_enabled;
	
	Engine.time_scale = 1;
	Global.pause_available = true;

	if Global.checkpoint_position != Vector2(0, 0):
		print("Spawning at checkpoint: " + str(Global.checkpoint_position))
		player.global_position = Global.checkpoint_position
	
	var killzone_hazards = get_tree().get_nodes_in_group("KillzoneHazard");
	for hazard in killzone_hazards:
		if !hazard.is_connected("player_died", _on_player_died):
			hazard.player_died.connect(_on_player_died);

# Connect all killzones to this method.
func _on_player_died() -> void:
	print("death relayed")
	level_reset_requested.emit();

# Connect the area2d ExitA signal to this method.
func _on_exit_a_reached() -> void:
	level_requested.emit(exit_a);
	Global.checkpoint_reached = false
	Global.checkpoint_position = Vector2(0, 0)

# Connect the area2d ExitB signal to this method.
func _on_exit_b_reached() -> void:
	level_requested.emit(exit_b);
	Global.checkpoint_reached = false
	Global.checkpoint_position = Vector2(0, 0)

# Connect the area2d PrevLevelTransition signal to this method.
func _on_prev_level_transition() -> void:
	level_requested.emit(previous_level, true);

# Move player to the end of the level.
# Used when moving back to this level from the next level
func jump_to_end() -> void:
	player.global_position = end_locator.global_position;

# Capture keypresses for fullscreen and pause.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		SettingsManager.toggle_fullscreen();
	if event.is_action_pressed("pause") && Global.pause_available:
		pause_menu_popup.open();
	if event.is_action_pressed("reset"):
		level_reset_requested.emit();
	if OS.is_debug_build():
		if event.is_action_pressed("skip_to_end"):
			jump_to_end()
		if event.is_action_pressed("skip_next"):
			level_requested.emit(exit_a);
		if event.is_action_pressed("skip_prev"):
			level_requested.emit(previous_level);

# Relay main menu request from pause menu.
func _on_pause_menu_popup_main_menu_requested() -> void:
	main_menu_requested.emit();

func _on_pause_menu_request_save() -> void:
	request_save.emit();

func get_level_music() -> AudioStream:
	return level_music

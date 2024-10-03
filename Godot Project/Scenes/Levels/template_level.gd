extends Node2D

# Signals connected to the game manager to control level loading.
signal level_reset_requested;
signal level_requested(level_path: String);
signal main_menu_requested;
signal request_save;

@onready var pause_menu_popup: Window = $PauseMenuPopup
@onready var player: CharacterBody2D = $Player
@onready var end_locator: Node2D = $EndLocator

## Paths to adjacent game levels.
## Give paths relative to res://Scenes/Levels and include .tscn
@export
var previous_level: String;
@export
var exit_a: String;
@export
var exit_b: String;

# Connect all killzones to this method.
func _on_player_died() -> void:
	print("death relayed")
	level_reset_requested.emit();

# Connect the area2d ExitA signal to this method.
func _on_exit_a_reached() -> void:
	level_requested.emit(exit_a);

# Connect the area2d ExitB signal to this method.
func _on_exit_b_reached() -> void:
	level_requested.emit(exit_b);

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
	if event.is_action_pressed("pause"):
		pause_menu_popup.open();

# Relay main menu request from pause menu.
func _on_pause_menu_popup_main_menu_requested() -> void:
	main_menu_requested.emit();


func _on_pause_menu_request_save() -> void:
	request_save.emit();

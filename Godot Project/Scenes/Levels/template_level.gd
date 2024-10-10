extends Node2D

# Signals connected to the game manager to control level loading.
signal level_reset_requested;
signal next_level_requested;
signal previous_level_requested;
signal main_menu_requested;

@onready var pause_menu_popup: Window = $PauseMenuPopup
@onready var player: CharacterBody2D = $Player
@onready var end_locator: Node2D = $EndLocator

func _ready() -> void:
	camera.position_smoothing_enabled = SettingsManager.camera_smoothing;
	camera.position_smoothing_speed = SMOOTHING_SPEED;
	
	if Global.checkpoint_position != Vector2(0, 0):
		print("Spawning at checkpoint: " + str(Global.checkpoint_position))
		player.global_position = Global.checkpoint_position

# Connect all killzones to this method.
func _on_player_died() -> void:
	print("death relayed")
	level_reset_requested.emit();
	
	if Global.checkpoint_reached:
		player.global_position = Global.checkpoint_position

# Connect the area2d level transition trigger to this method.
func _on_level_transition_reached() -> void:
	next_level_requested.emit();

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
	previous_level_requested.emit()

func _jump_to_end() -> void:
	player.global_position = end_locator.global_position;

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		SettingsManager.toggle_fullscreen();
	if event.is_action_pressed("pause"):
		pause_menu_popup.open();

func _on_pause_menu_popup_main_menu_requested() -> void:
	main_menu_requested.emit();

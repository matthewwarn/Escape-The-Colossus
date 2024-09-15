extends Node

# Signals connected to the game manager to control level loading.
signal level_reset_requested;
signal next_level_requested;
signal main_menu_requested;

@onready var pause_menu_popup: Window = $PauseMenuPopup

# Connect all killzones to this method.
func _on_player_died() -> void:
	print("death relayed")
	level_reset_requested.emit();

# Connect the area2d level transition trigger to this method.
func _on_level_transition_reached() -> void:
	print("level transition relayed")
	next_level_requested.emit();

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_menu_popup.open();

func _on_pause_menu_popup_main_menu_requested() -> void:
	main_menu_requested.emit();

extends Window

signal main_menu_requested;
@onready var settings_menu: Control = $SettingsMenu
@onready var resume_button: Button = $PauseMenu/MarginContainer/VBoxContainer/ResumeButton
@onready var settings_button: Button = $PauseMenu/MarginContainer/VBoxContainer/SettingsButton

func open() -> void:
	get_tree().paused = true;
	resume_button.grab_focus();
	show();

func close() -> void:
	hide();
	get_tree().paused = false;

# Reqeust main menu  open
func _on_main_menu_button_pressed() -> void:
	close();
	main_menu_requested.emit();

# Quit the game
func _on_quit_button_pressed() -> void:
	get_tree().quit(0);

# Dismiss pause menu if pause key pressed
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		close();

func _on_settings_button_pressed() -> void:
	settings_menu.show();

func _on_settings_menu_hidden() -> void:
	settings_button.grab_focus();

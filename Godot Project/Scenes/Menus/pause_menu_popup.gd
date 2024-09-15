extends Window

signal main_menu_requested;

func open() -> void:
	get_tree().paused = true;
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

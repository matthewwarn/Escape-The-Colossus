extends CheckButton

signal request_save;

func _update() -> void:
	set_pressed_no_signal(
		SettingsManager.is_fullscreen()
	);

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	SettingsManager.set_fullscreen(toggled_on);
	request_save.emit();
	

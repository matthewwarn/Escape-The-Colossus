extends Node

func is_fullscreen() -> bool:
	return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN;

func toggle_fullscreen() -> void:
	if is_fullscreen():
		set_fullscreen(false);
	else:
		set_fullscreen(true);

func set_fullscreen(fullscreen_enabled: bool) -> void:
	if (fullscreen_enabled):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);

extends Node

var camera_smoothing: bool = true;
var speedrun_timer: bool = false;

func is_fullscreen() -> bool:
	return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN;

func toggle_fullscreen() -> void:
	if is_fullscreen():
		set_fullscreen(false);
	else:
		set_fullscreen(true);

func set_fullscreen(fullscreen_enabled: bool) -> void:
	if (fullscreen_enabled):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN);
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);


func get_linear_volume(bus_name: String):
	var bus_index = AudioServer.get_bus_index(bus_name);
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index));


func set_linear_volume(bus_name: String, volume: float):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index(bus_name),
		linear_to_db(volume)
	);

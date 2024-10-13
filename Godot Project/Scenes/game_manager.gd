extends Node

const GAME_SAVE_PATH: String = "user://save.dat";
const FALLBACK_SAVE: String  = "res://fallback_save.dat";
const MAIN_MENU: String      = "Scenes/Menus/main_menu.tscn";
const SETTINGS_MENU: String  = "Scenes/Menus/settings_menu.tscn";

@onready var audio_manager = $AudioManager

## Path to first level of the game. Relative to LEVEL_ROOT_DIR
var FIRST_LEVEL: String = "Tutorial/integrated_tutorial.tscn";
## Path from which all level paths are given relative to.
const LEVEL_ROOT_DIR: String = "Scenes/Levels/";

var DEFAULT_SAVE: Dictionary = {
	"current_level": FIRST_LEVEL,
	"fullscreen": false,
	"camera smoothing": true,
	"double jump": false,
	"dash": false,
	"speedrun enabled": false,
}

var SAVE_KEYS: Array = [
	'current_level',
	'fullscreen',
	'camera smoothing',
	'double jump',
	'dash',
	'speedrun enabled'
]

var current_level: Node;
var current_level_path: String;

var speedrun_time: float = 0;

## When godot finishes loading game manager, load the main menu.
func _ready() -> void:
	load_level(MAIN_MENU);
	current_level_path = read_save();

## Called when main menu new game button pressed.
func start_game() -> void:
	Abilities.dash_enabled = false;
	Abilities.double_jump_enabled = false;
	load_level(FIRST_LEVEL);

## Called when main menu resume game button pressed.
func resume_game() -> void:
	current_level_path = read_save();
	load_level(current_level_path);

## Return to main menu from pause menu in game.
func open_main_menu() -> void:
	load_level(MAIN_MENU);


## Save game state to file.
func save_game() -> void:
	print("Saving at ", current_level_path)
	var save_data = {
		"current_level": current_level_path,
		"fullscreen": SettingsManager.is_fullscreen(),
		"camera smoothing": SettingsManager.camera_smoothing,
		"speedrun enabled": SettingsManager.speedrun_timer,
		"double jump": Abilities.double_jump_enabled,
		"dash": Abilities.dash_enabled,
	}
	var serialised_data = JSON.stringify(save_data);
	var file = FileAccess.open(GAME_SAVE_PATH, FileAccess.WRITE);
	file.store_string(serialised_data);


## Read previous game state from file.
## returns path to current level in save.
func read_save() -> String:
	# Try to read the save file
	var file = FileAccess.open(GAME_SAVE_PATH, FileAccess.READ);
	# New installations will not have a game save file so we need to load a default one instead.
	if file == null:
		return apply_save(DEFAULT_SAVE);
	
	# Parse the save file
	var serialised_data = file.get_as_text();
	var json = JSON.new();
	var parse_error = json.parse(serialised_data);
	
	# Check save file validity and apply if correct
	if (parse_error == OK):
		var save_data = json.data;
		if (typeof(save_data) == TYPE_DICTIONARY):
			if check_dict_validity(SAVE_KEYS, save_data):
				print("valid")
				return apply_save(save_data)
			else:
				print("Save file missing attribute");
		else:
			print("save data corrupt.");
	else:
		print("Parse error in save file: ", json.get_error_message());
	
	# Save file is invalid, use the default.
	return apply_save(DEFAULT_SAVE);


## Apply the data from a save file to the game's global scripts
func apply_save(data: Dictionary) -> String:
	SettingsManager.set_fullscreen(data["fullscreen"])
	SettingsManager.camera_smoothing = data["camera smoothing"];
	Abilities.double_jump_enabled    = data["double jump"];
	Abilities.dash_enabled           = data["dash"];
	SettingsManager.speedrun_timer   = data["speedrun enabled"];
	print(data['current_level'])
	return data["current_level"];


func check_dict_validity(keys: Array, dict: Dictionary) -> bool:
	for key in keys:
		if !dict.has(key):
			return false;
	return true;


## Load Level
##
## Calls to deferred method, no need to call this method deferred.
## [param jump_to_end] Whether to move player to the end of the new level.
func load_level(level_path: String, jump_to_end: bool = false) -> void:
	call_deferred("_load_level_deferred", level_path, jump_to_end);

## Load a scene and connect all its signals
func _load_level_deferred(level_path: String, jump_to_end: bool = false) -> void:
	## Needed as when this is called in _ready there is no loaded level.
	if (current_level != null):
		remove_child(current_level);
		current_level.call_deferred("free");
	
	var next_level_preload;
	if (level_path == MAIN_MENU):
		next_level_preload = load(level_path);
	else:
		next_level_preload = load(LEVEL_ROOT_DIR + level_path);
		current_level_path = level_path;
	
	current_level = next_level_preload.instantiate();
	add_child(current_level);
	
	if current_level.has_method("get_level_music"):
		var song = current_level.get_level_music()
		audio_manager.play_music(song)
	
	# Connect signals
	if (level_path == MAIN_MENU):
		current_level.connect("game_start_requested", start_game);
		current_level.connect("game_resume_requested", resume_game);
		current_level.connect("request_save", save_game);
	else:
		current_level.connect("level_reset_requested", reload_level);
		current_level.connect("level_requested", load_level);
		current_level.connect("main_menu_requested", open_main_menu);
		current_level.connect("request_save", save_game);
		save_game();
		# When moving to a previous level, we need to jump to the end of the level.
		if (jump_to_end):
			current_level.jump_to_end();
	

# Reload current level on player death.
func reload_level() -> void:
	load_level(current_level_path);

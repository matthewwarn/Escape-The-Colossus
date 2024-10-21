extends Node

signal level_load_complete;

const GAME_SAVE_PATH: String = "user://save.dat";
const MAIN_MENU: String      = "Scenes/Menus/main_menu.tscn";
const SETTINGS_MENU: String  = "Scenes/Menus/settings_menu.tscn";

## Used to play each level's soundtrack.
@onready var audio_manager = $AudioManager
## Used to fade screen while loading a level.
@onready var screen_overlay: CanvasLayer = $ScreenOverlay

## Path to first level of the game. Relative to LEVEL_ROOT_DIR
var FIRST_LEVEL: String = "Tutorial/integrated_tutorial.tscn";
## Path from which all level paths are given relative to.
const LEVEL_ROOT_DIR: String = "Scenes/Levels/";

## When the save file on a user's computer is not usable, use this instead.
var DEFAULT_SAVE: Dictionary = {
	"current_level": FIRST_LEVEL,
	"fullscreen": false,
	"camera smoothing": true,
	"double jump": false,
	"dash": false,
	"speedrun enabled": false,
	"speedrun time": 0,
	"core one defeated": false,
	"core two defeated": false,
	"Master": 1.0,
	"Music": 1.0,
	"SFX": 1.0,
}

## A save file must contain all of these attributes to be considered valid.
var SAVE_KEYS: Array = [
	'current_level',
	'fullscreen',
	'camera smoothing',
	'double jump',
	'dash',
	'speedrun enabled',
	"speedrun time",
	"core one defeated",
	"core two defeated",
	"Master",
	"Music",
	"SFX",
]

## Reference to root of currently loaded scene.
var current_level: Node;
## Path to .tscn file for currently loaded scene.
var current_level_path: String;


## When godot finishes loading game manager, load the main menu.
func _ready() -> void:
	load_level(MAIN_MENU);
	current_level_path = read_save();

## Called when main menu new game button pressed.
## Reset the player's position, abilities, and speedrun time.
func start_game() -> void:
	load_level(FIRST_LEVEL);
	await self.level_load_complete;
	Abilities.dash_enabled = false;
	Abilities.double_jump_enabled = false;
	Global.speedrun_time = 0.0;
	Global.core_one_defeated = false;
	Global.core_two_defeated = false;
	save_game()

## Called when main menu resume game button pressed.
## Resume the most recent save.
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
		"speedrun time": snapped(Global.speedrun_time, 0.0001),
		"double jump": Abilities.double_jump_enabled,
		"dash": Abilities.dash_enabled,
		"core one defeated": Global.core_one_defeated,
		"core two defeated": Global.core_two_defeated,
		"Master": snapped(SettingsManager.get_linear_volume("Master"), 0.01),
		"Music": snapped(SettingsManager.get_linear_volume("Music"), 0.01),
		"SFX": snapped(SettingsManager.get_linear_volume("SFX"), 0.01),
	}
	var serialised_data = JSON.stringify(save_data, "\t");
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
	SettingsManager.set_fullscreen(data["fullscreen"]);
	SettingsManager.set_linear_volume("Master", data["Master"]);
	SettingsManager.set_linear_volume("Music", data["Music"]);
	SettingsManager.set_linear_volume("SFX", data["SFX"]);
	SettingsManager.camera_smoothing = data["camera smoothing"];
	Abilities.double_jump_enabled    = data["double jump"];
	Abilities.dash_enabled           = data["dash"];
	SettingsManager.speedrun_timer   = data["speedrun enabled"];
	Global.speedrun_time             = data["speedrun time"];
	Global.core_one_defeated         = data["core one defeated"];
	Global.core_two_defeated         = data["core two defeated"];
	return data["current_level"];


## Check that the given dictionary has all the attributes required to be a valid save file.
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
	# Condition needed as when this is called in _ready there is no loaded level.
	if (current_level != null):
		# Unload the current level.
		remove_child(current_level);
		current_level.call_deferred("free");
	
	# Load level as resource from file.
	var next_level_preload;
	if (level_path == MAIN_MENU):
		next_level_preload = load(level_path);
	else:
		next_level_preload = load(LEVEL_ROOT_DIR + level_path);
		current_level_path = level_path;
	
	# Create instance of level and add as child to scene tree.
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
	
	level_load_complete.emit();
	

## Reload current level on player death.
func reload_level() -> void:
	# Fade the screen to black
	screen_overlay.auto_fade();
	# Wait until the screen is black before unloading the level.
	# This masks the brief freeze when reloading the level.
	await screen_overlay.fade_complete;
	load_level(current_level_path);

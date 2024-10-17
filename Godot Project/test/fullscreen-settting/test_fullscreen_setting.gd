extends GutTest

var game_manager: Node;
var sender;
var state;

## Load an instance of the game to conduct tests on 
func load_game():
	game_manager = load("res://Scenes/game_manager.tscn").instantiate();
	add_child_autofree(game_manager);
	# This delay is important as it gives the game manager time to load the main menu..
	await get_tree().create_timer(0.1).timeout
	sender = get_sender(game_manager);


## Get an object to simulate user input
func get_sender(game_manager: Node):
	var menu = game_manager.get_node("Main Menu")
	return InputSender.new(menu);


## Load the game to test
func before_each():
	print("before each")
	load_game();
	# Leave this delay. Without it GUT will start testing before loading the sender.
	await get_tree().create_timer(0.1).timeout


## Clear the sender to avoid accidentally leaving a key pressed.
func after_each():
	sender.release_all();
	sender.clear();

## Press and then release an inputevent
func press_action(command: String):
	sender.action_down(command).wait(0.1);
	sender.action_up(command).wait(0.1);
	await(sender.idle)


## Test that pressing the fullscreen keyboard command toggled the fullscreen state.
func test_fullscreen_toggle():
	var original_state: bool = SettingsManager.is_fullscreen();
	# simulate input
	press_action("fullscreen");
	# test new state
	assert_eq(SettingsManager.is_fullscreen(), !original_state)
	state = SettingsManager.is_fullscreen()


## Test that the state from the previous test remains after the game is reloaded in before_each()
func test_fullscreen_save():
	assert_eq(state, SettingsManager.is_fullscreen())

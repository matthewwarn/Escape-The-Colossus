extends GutTest

var game_manager: Node;

## Load the game to test
func before_each():
	game_manager = load("res://Scenes/game_manager.tscn").instantiate();
	add_child_autofree(game_manager);
	# 
	await get_tree().create_timer(0.1).timeout

## Test that pressing the fullscreen keyboard command toggled the fullscreen state.
func test_fullscreen_toggle():
	var original_state: bool = SettingsManager.is_fullscreen();
	var menu = game_manager.get_node("Main Menu")
	var sender = InputSender.new(menu);
	
	sender.action_down("fullscreen")
	
	assert_eq(SettingsManager.is_fullscreen(), !original_state)

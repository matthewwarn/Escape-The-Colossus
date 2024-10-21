extends GutTest

# Variable to hold the instance of the scene
var scene_instance

# Load the scene once at the beginning of each test
func loadScene():
	# Load the scene at runtime
	var scene = load("res://Scenes/Levels/Tutorial/managePopupMessages.gd")
	scene_instance = scene.instance()
	
	# Add the scene to the active scene tree
	get_tree().current_scene.add_child(scene_instance)
	scene_instance._ready()  # Call _ready() if needed

func removeInstance():
	# Remove the instance after each test to keep tests isolated
	scene_instance.queue_free()

func test_arrow_key_input():
	# Simulate pressing the right arrow key
	var event = InputEventAction.new()
	event.action = "move_right"
	event.pressed = true

	# Call _input to process the simulated event
	scene_instance._input(event)

	# Access the Timer node using get_node
	var timer = scene_instance.get_node("Timer")
	
	# Check if arrow_pressed was set to true
	assert_true(scene_instance.arrow_pressed, "arrow_pressed should be true after pressing 'move_right'")

	# Check if the timer started
	assert_true(not timer.is_stopped(), "Timer should have started after pressing 'move_right'")

func test_space_key_input_without_message():
	# Simulate pressing space bar before message_finished is true
	var event = InputEventAction.new()
	event.action = "jump"
	event.pressed = true

	# Call _input to process the simulated event
	scene_instance._input(event)

	# Check that space_pressed is still false because message_finished is false
	assert_false(scene_instance.space_pressed, "space_pressed should be false when message_finished is false")

func test_space_key_input_with_message():
	# Set message_finished to true to allow space bar input
	scene_instance.message_finished = true

	# Simulate pressing space bar after message_finished is true
	var event = InputEventAction.new()
	event.action = "jump"
	event.pressed = true

	# Call _input to process the simulated event
	scene_instance._input(event)

	# Access the Timer2 node using get_node
	var timer2 = scene_instance.get_node("Timer2")

	# Check if space_pressed was set to true
	assert_true(scene_instance.space_pressed, "space_pressed should be true after pressing 'jump'")

	# Check if the second timer started
	assert_true(not timer2.is_stopped(), "Timer2 should have started after pressing 'jump'")

func test_timer_timeout():
	# Simulate timer timeout
	scene_instance._on_timer_timeout()

	# Check if the arrow fade animation is playing
	assert_true(scene_instance.animation.is_playing(), "Arrow fade animation should be playing")

	# Check if the space appear animation is playing
	assert_true(scene_instance.animation2.is_playing(), "Space appear animation should be playing")

	# Check if message_finished was set to true
	assert_true(scene_instance.message_finished, "message_finished should be true after timer timeout")

func test_timer2_timeout():
	# Simulate timer2 timeout
	scene_instance._on_timer2_timeout()

	# Check if the space fade animation is playing
	assert_true(scene_instance.animation2.is_playing(), "Space fade animation should be playing")

	# Check if the title animation is playing
	assert_true(scene_instance.animation3.is_playing(), "Title appear and fade animation should be playing")

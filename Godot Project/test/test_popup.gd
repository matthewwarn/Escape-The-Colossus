extends GutTest

# Variable to hold the instance of the scene
var scene_instance

# Load the scene once at the beginning of each test
func loadScene():
	# Load the scene at runtime
	var scene = load("res://Scenes/Levels/Tutorial/integrated_tutorial.tscn")
	assert_true(scene != null, "Scene should be loaded successfully")
	scene_instance = scene.instantiate()
	assert_true(scene_instance != null, "Scene instance should be instantiated")
	
	# Add the scene to the active scene tree
	get_tree().root.add_child(scene_instance)
	assert_true(scene_instance.is_inside_tree(), "Scene instance should be added to the scene tree")

func removeInstance():
	# Remove the instance after each test to keep tests isolated
	if scene_instance:
		scene_instance.queue_free()

func test_arrow_key_input():
	# Load the scene dynamically
	loadScene()

	# Access the CanvasLayer node
	var canvas_layer = scene_instance.get_node("CanvasLayer")
	assert_true(canvas_layer != null, "CanvasLayer node should be accessible")

	# Simulate pressing the right arrow key (move_right action)
	var event = InputEventAction.new()
	event.action = "move_right"
	event.pressed = true

	# Call the _input method directly to process the simulated event
	canvas_layer._input(event)

	# Check if arrow_pressed is true
	assert_true(canvas_layer.arrow_pressed, "arrow_pressed should be true after pressing 'move_right'")

	# Additionally, check if the timer started
	var timer = canvas_layer.get_node("Timer")  # Adjust the path if necessary
	assert_true(timer != null, "Timer node should exist")
	assert_true(not timer.is_stopped(), "Timer should have started after pressing 'move_right'")

func test_space_key_input_without_message():
	# Load the scene dynamically
	loadScene()

	# Access the CanvasLayer node
	var canvas_layer = scene_instance.get_node("CanvasLayer")
	assert_true(canvas_layer != null, "CanvasLayer node should be accessible")

	# Simulate pressing the space bar before message_finished is true
	var event = InputEventAction.new()
	event.action = "jump"
	event.pressed = true

	# Call the _input method directly to process the simulated event
	canvas_layer._input(event)

	# Check that space_pressed is still false because message_finished is false
	assert_false(canvas_layer.space_pressed, "space_pressed should be false when message_finished is false")

func test_space_key_input_with_message():
	# Load the scene dynamically
	loadScene()

	# Access the CanvasLayer node
	var canvas_layer = scene_instance.get_node("CanvasLayer")
	assert_true(canvas_layer != null, "CanvasLayer node should be accessible")

	# Set message_finished to true to allow space bar input
	canvas_layer.message_finished = true

	# Simulate pressing the space bar
	var event = InputEventAction.new()
	event.action = "jump"
	event.pressed = true

	# Call the _input method directly to process the simulated event
	canvas_layer._input(event)

	# Check if space_pressed is set to true
	assert_true(canvas_layer.space_pressed, "space_pressed should be true after pressing 'jump'")

	# Access the second timer node using get_node
	var timer2 = canvas_layer.get_node("Timer2")  # Adjust the path if necessary
	assert_true(timer2 != null, "Timer2 node should exist")

	# Check if the second timer started
	assert_true(not timer2.is_stopped(), "Timer2 should have started after pressing 'jump'")

# Gut-specific setup for loading and unloading the scene
func before_each():
	loadScene()

func after_each():
	removeInstance()

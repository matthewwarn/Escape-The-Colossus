extends GutTest

#TEST 1: Checking if the timer initializes correctly
func test_timer_initialization():
	#Preloading the speedrun timer scene and making an instance of it
	var timer_scene = preload("res://Scenes/speedrun.tscn")
	var timer_scene_instance = timer_scene.instantiate()
	
	#Add this instance to the scene tree
	add_child(timer_scene_instance)
	
	#Check if the timer starts at 0.0 seconds
	assert_eq(timer_scene_instance.time, 0.0, "The timer should initialize to 0.")

#TEST 2: Checking if the timer increases over time
func test_timer_increases_over_time():
	#Preloading the speedrun timer scene and making an instance of it
	var timer_scene = preload("res://Scenes/speedrun.tscn")
	var timer_scene_instance = timer_scene.instantiate()
	
	#Add this instance to the scene tree
	add_child(timer_scene_instance) 
	
	#Set speedrun time to 0
	Global.speedrun_time = 0.0
	timer_scene_instance.time = Global.speedrun_time
	
	#Simulate 5 seconds of time with _physics_process
	for i in range(5):
		timer_scene_instance._physics_process(1.0)
	
	#Check if the time correctly increased by 5 seconds
	assert_eq(timer_scene_instance.time, 5.0, "The timer should have increased by 5 seconds.")

#TEST 3: Checking if the timer formats correctly
func test_timer_formatting():
	#Preloading the speedrun timer scene and making an instance of it
	var timer_scene = preload("res://Scenes/speedrun.tscn")
	var timer_scene_instance = timer_scene.instantiate()
	add_child(timer_scene_instance)
	
	#Set the time to 2 minutes and 5.58 seconds
	timer_scene_instance.time = 125.58
	timer_scene_instance.update_ui() 
	
	#Check if the timer has formatted to 02:05.58 instead of 125.58
	assert_eq(timer_scene_instance.formatted_time, "02:05.58", "The timer should format correctly.")

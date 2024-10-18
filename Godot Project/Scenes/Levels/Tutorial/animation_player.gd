extends AnimationPlayer

var arrow_pressed = false     # Check if arrow key has been pressed
var space_pressed = false     # Check if space bar has been pressed
var message_finished = false  # Check if message animation has finished

# Called when the node enters the scene tree for the first time.
func _ready():
	play("appear_arrow")     # Play animation
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))      # Connect timer
	$Timer2.connect("timeout", Callable(self, "_on_timer2_timeout"))
	
# Check if user pressed arrow key and space bar
func _input(event):
	if event.is_action_pressed("move_right") and not arrow_pressed:
		$Timer.start()                 # Timer start when arrow key pressed
		arrow_pressed = true
	if event.is_action_pressed("jump") and not space_pressed and message_finished:
		$Timer2.start()               # Timer start when space bar pressed
		space_pressed = true
		
func _on_timer_timeout():
	play("fade_and_appear")        # Play animation when timeout
	message_finished = true
	
func _on_timer2_timeout():         # Play animation when timeout
	play("fade_space")
	

		

		
		
	  
	

	
	

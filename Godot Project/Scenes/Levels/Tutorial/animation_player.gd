extends AnimationPlayer

var arrow_pressed = false
var space_pressed = false
var message_finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	play("appear_arrow")
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	$Timer2.connect("timeout", Callable(self, "_on_timer2_timeout"))
	
# Check if user pressed arrow key and space bar
func _input(event):
	if event.is_action_pressed("move_right") and not arrow_pressed:
		$Timer.start()
		arrow_pressed = true
	if event.is_action_pressed("jump") and not space_pressed and message_finished:
		$Timer2.start()
		space_pressed = true
		
func _on_timer_timeout():
	play("fade_and_appear")
	message_finished = true
	
func _on_timer2_timeout():
	play("fade_space")
	

		

		
		
	  
	

	
	

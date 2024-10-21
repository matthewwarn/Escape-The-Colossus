extends CanvasLayer

var arrow_pressed = false
var space_pressed = false
var message_finished = false

@onready var animation: AnimationPlayer = $"../CanvasLayer/Key instruction(arrow)/AnimationPlayer"
@onready var animation2: AnimationPlayer = $"../CanvasLayer/Key instruction(space)/AnimationPlayer2"
@onready var animation3: AnimationPlayer = $"../CanvasLayer/Title/AnimationPlayer3"

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("arrow appear")
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
	animation.play("arrow fade")
	animation2.play("space appear")
	message_finished = true
	
func _on_timer2_timeout():
	animation2.play("space fade")
	animation3.play("title appear and fade")
	

		

		
		
	  
	

	
	

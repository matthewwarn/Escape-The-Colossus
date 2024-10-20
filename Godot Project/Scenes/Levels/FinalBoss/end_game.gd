extends Area2D

@onready var fade_rect = $"../WhiteScreen/ColorRect"
@onready var info = $Info
@onready var completion_time_label = $Info/Label

@onready var clear_animation = $Info/AnimationPlayer


@export var fade_speed: float = 0.5
@export var time_scale: float = 0.4


var completion_time: float

func _ready():
	# Set white screen to transparent
	fade_rect.color = Color(1, 1, 1, 0)
	
	# Set final info to invisible
	info.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		# Record final completion time
		completion_time = Global.speedrun_time
		completion_time_label.text = "Completion Time: " + Global.formatted_time
		
		# Play Music
		$Song3Player.play()
		
		# Slow time
		Engine.time_scale = time_scale
		
		# Start fade to white
		await fade_to_white()
		
		time_scale = 1
		
		# Show info on screen after fade completes
		show_info()
		

func fade_to_white():
	while fade_rect.color.a < 1:
		var current_alpha = fade_rect.color.a
		current_alpha += fade_speed * get_process_delta_time()
		
		fade_rect.color = Color(1, 1, 1, min(current_alpha, 1))
		
		await get_tree().create_timer(0.01).timeout

func show_info():
	info.visible = true
	
	if !clear_animation.is_playing():
		clear_animation.play("clear")

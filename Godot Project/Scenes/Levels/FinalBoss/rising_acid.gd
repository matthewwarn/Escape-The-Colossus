extends Node2D

var speed: int = 20
var direction = Vector2(0, -1)
var heart_hits: int = 0;
var acid_active = false;

func _ready():
	position.x = 5000
	$Song1Player.play()

func _process(delta):
	if acid_active:
		rise_acid(delta)

func _on_area_2d_heart_destroyed_signal():
	#Switch Song
	$Song1Player.stop()
	$Song2Player.play()
	
	$AcidSFX.play()
	
	acid_active = true;

func rise_acid(delta):
	#Make acid appear
	position.x = 0
	
	#When the acid is moving up
	if(direction == Vector2(0, -1)):
		#Varying levels of speed throughout the level
		if(position.y <= -200 and position.y >= -1900):
			speed = 57
		
		if(position.y <= -1900 and position.y >= -2564):
			speed = 80
		
		#move until it reaches the skull
		if(position.y >= -2564):
			translate(direction * speed * delta)
		
		if(position.y <= -2390):
			await get_tree().create_timer(3).timeout
			
			#Reverse direction and go back down
			speed = 30
			direction = Vector2(0, 1)
			translate(direction * speed * delta)
	
	#When the acid is moving down
	elif(direction == Vector2(0, 1)):
		#At a certain point, disappear
		await get_tree().create_timer(3).timeout
		position.x = 5000
		acid_active = false

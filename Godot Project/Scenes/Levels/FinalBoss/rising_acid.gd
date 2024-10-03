extends Node2D

var speed: int = 20
var direction = Vector2(0, -1)
var heart_hits: int = 0;
var acid_active = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = 5000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if acid_active:
		rise_acid(delta)

func _on_area_2d_heart_destroyed_signal():
	#play monster roar sfx
	#destroy tunnel blockage
	#enable acid
	#play escape music
	acid_active = true;

func rise_acid(delta):
	position.x = 0
	
	#when reach bottom of tunnel, speed up
	if(position.y <= -200):
		speed = 57
	
	#move until it reaches the skull
	if(position.y >= -2564):
		translate(direction * speed * delta)

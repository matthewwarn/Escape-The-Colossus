extends Node2D

var speed: int = 25
var direction = Vector2(0, -1)
var heart_hits: int = 0;
var acid_active = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	activate_acid(delta)
	
func activate_acid(delta):
	#check for heart attack
	#play squishy blood sfx
	#heart_hits++
	
	#When heart is destroyed
	if(heart_hits == 3){
		#disable heart
		#play monster roar sfx
		#enable acid
		acid_active = true
	}
	
	if(acid_active == true):
		rise_acid(delta)

func rise_acid(delta):
	#when reach bottom of tunnel, speed up
	if(position.y <= -200):
		speed = 55
	
	#move until it reaches the skull
	if(position.y >= -2564):
		translate(direction * speed * delta)

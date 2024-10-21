extends AnimationPlayer

var end_reached: bool
var animation_played: bool

func _ready():
	end_reached = false
	animation_played = false
	
func _physics_process(_delta):
	print("anim played" + str(animation_played))
	print("end_reached" + str(end_reached))
	
	if end_reached == true && animation_played == false:
		animation_played = true
		play_clear_animation()

func play_clear_animation():
	print("playing animation")
	if not is_playing():
		play("clear")

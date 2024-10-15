extends CanvasLayer

signal fade_complete

@onready var animation_player: AnimationPlayer = $AnimationPlayer

## Fade screen to black and then back to transparent.
func auto_fade():
	animation_player.play(&"fade_to_black");
	await animation_player.animation_finished
	fade_complete.emit();
	animation_player.play_backwards(&"fade_to_black");

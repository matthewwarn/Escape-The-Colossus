extends Node

class_name AudioManager

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer

var current_music: AudioStream = null

func play_music(new_music: AudioStream):
	#Don't restart the track if it's the same
	if current_music == new_music:
		return
	
	#Set new track and play that
	current_music = new_music
	audio_player.stream = current_music
	
	audio_player.play()


func stop_music():
	audio_player.stop()
	current_music = null


func play_roar():
	sfx_player.play();

extends Control

signal game_start_requested;

func _on_play_button_pressed():
	game_start_requested.emit();


func _on_options_button_pressed():
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit()

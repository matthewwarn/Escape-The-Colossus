extends Control

signal game_start_requested;
signal game_resume_requested;

func _ready():
	$MarginContainer/VBoxContainer/ResumeButton.grab_focus()

func _on_play_button_pressed():
	game_start_requested.emit();

func _on_resume_button_pressed() -> void:
	game_resume_requested.emit();

func _on_options_button_pressed():
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit();

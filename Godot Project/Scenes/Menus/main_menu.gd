extends Control

signal game_start_requested;
signal game_resume_requested;
signal settings_menu_requested;

@onready var resume_button: Button = $MarginContainer/VBoxContainer/ResumeButton

func _ready() -> void:
	# Starting point for keyboard navigation.
	resume_button.grab_focus();

func _on_play_button_pressed():
	game_start_requested.emit();

func _on_resume_button_pressed() -> void:
	game_resume_requested.emit();

func _on_options_button_pressed():
	settings_menu_requested.emit();


func _on_quit_button_pressed():
	get_tree().quit();

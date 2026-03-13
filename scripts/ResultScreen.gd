extends Control

@export var title_text: String = "You Win!"
@export var subtitle_text: String = "Press retry to play again."
@export var restart_scene_path: String = "res://scenes/Main.tscn"

@onready var title_label: Label = $CenterContainer/VBoxContainer/Title
@onready var subtitle_label: Label = $CenterContainer/VBoxContainer/Subtitle
@onready var retry_button: Button = $CenterContainer/VBoxContainer/Buttons/RetryButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/Buttons/QuitButton

func _ready() -> void:
	title_label.text = title_text
	subtitle_label.text = subtitle_text
	retry_button.pressed.connect(_on_retry_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file(restart_scene_path)

func _on_quit_pressed() -> void:
	get_tree().quit()

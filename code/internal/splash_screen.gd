extends Control

@onready var animation_player = $AnimationPlayer

func to_main_menu():
	await Fade.fade_out().finished
	get_tree().change_scene_to_file("res://scenes/main-menu.tscn")
	Fade.fade_in()

func _input(event: InputEvent) -> void:
	if(event is InputEventKey):
		to_main_menu()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	to_main_menu()

func _ready() -> void:
	animation_player.play("splash")
	pass

extends Control

@onready var footsteps = $"Panel/Footstep Particles"

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	footsteps.emitting = true
	pass

func _on_play_pressed() -> void:
	await Fade.fade_out().finished
	get_tree().change_scene_to_file("res://scenes/op-scene.tscn")
	Fade.fade_in()

func _on_quit_pressed() -> void:
	get_tree().quit()

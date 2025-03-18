extends Control
	
@onready var audio_stream = $AudioStreamPlayer
@onready var footsteps = $"Panel/Footstep Particles"

const mute_db := -80.0 # To mute the audio player
const fade_time := 2.0 # The time it takes to fade in/out in seconds

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	footsteps.emitting = true
	pass

func _on_play_pressed() -> void:
	fade_music_out()
	await Fade.fade_out().finished
	get_tree().change_scene_to_file("res://scenes/op-scene.tscn")
	Fade.fade_in()

func _on_quit_pressed() -> void:
	fade_music_out()
	await get_tree().create_timer(1.0).timeout
	await Fade.fade_out().finished
	get_tree().quit()

func fade_music_out() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(audio_stream, "volume_db", mute_db, fade_time)

extends Area3D

@onready var parent = get_parent_node_3d()
@onready var audio_stream = parent.get_node("AudioStreamPlayer")
@export_file("*.tscn") var scene

@export var fade_time := 2
const mute_db := -80.0

func interact():
	fade_music_out()
	await Fade.fade_out().finished
	get_tree().change_scene_to_file(scene)
	Fade.fade_in()


func fade_music_out() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(audio_stream, "volume_db", mute_db, fade_time)

extends AudioStreamPlayer

@onready var audio_stream = $"."
@export var fade_time := 2
const mute_db := -80.0

func fade_music_out() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(audio_stream, "volume_db", mute_db, fade_time)

func muteValue():
	return mute_db

func fadeTime():
	return fade_time

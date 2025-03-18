extends Control

var monologue = load("res://code/dialogue/opening.dialogue")
@onready var footsteps:CPUParticles2D = $"Footstep Particles"
@onready var root_node : Control = $"."
@onready var audio_stream = $AudioStreamPlayer

const mute_db := -80.0 # To mute the audio player
const fade_time := 2.0 # The time it takes to fade in/out in seconds

func _ready() -> void:
	DialogueManager.show_dialogue_balloon(monologue)
	await get_tree().create_timer(1.0).timeout
	footsteps.emitting = true
	Engine.get_singleton("DialogueManager").dialogue_ended.connect(_on_monologue_end)
	pass

func _process(delta: float) -> void:
	pass

func _on_monologue_end(resource) -> void:
	fade_music_out()
	await Fade.fade_out().finished
	get_tree().change_scene_to_file("res://scenes/first-room.tscn")
	Fade.fade_in()

func fade_music_out() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(audio_stream, "volume_db", mute_db, fade_time)

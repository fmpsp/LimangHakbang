extends Node3D

var tutorial = load("res://code/dialogue/tutorial.dialogue")
@onready var audio_stream = $AudioStreamPlayer

func _ready() -> void:
	get_tree().paused = true
	await get_tree().create_timer(1.25).timeout
	get_tree().paused = false
	DialogueManager.show_dialogue_balloon(tutorial)
	pass

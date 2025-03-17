extends Control

var monologue = load("res://code/dialogue/opening.dialogue")
@onready var footsteps:CPUParticles2D = $"Footstep Particles"
@onready var root_node : Control = $"."

func _ready() -> void:
	DialogueManager.show_dialogue_balloon(monologue)
	await get_tree().create_timer(1.0).timeout
	footsteps.emitting = true
	Engine.get_singleton("DialogueManager").dialogue_ended.connect(_on_monologue_end)
	pass

func _process(delta: float) -> void:
	pass

func _on_monologue_end(resource) -> void:
	await Fade.fade_out().finished
	get_tree().change_scene_to_file("res://scenes/white-room.tscn")
	Fade.fade_in()

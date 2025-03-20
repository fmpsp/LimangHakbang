extends Node3D

var end = load("res://code/dialogue/end.dialogue")

var dialogue_done = false

func _ready() -> void:
	get_tree().paused = true
	await get_tree().create_timer(1.25).timeout
	get_tree().paused = false
	DialogueManager.show_dialogue_balloon(end)
	Engine.get_singleton("DialogueManager").dialogue_ended.connect(_on_monologue_end)
	pass

func _process(_delta: float) -> void:
	if dialogue_done:
		if Input.is_action_just_pressed("menu"):
			%"menu-options".show()


func _on_resume_pressed() -> void:
	%"menu-options".hide()

func _on_quit_pressed() -> void:
	await Fade.fade_out().finished
	get_tree().quit()

func _on_monologue_end(_resource) -> void:
	dialogue_done = true
	pass

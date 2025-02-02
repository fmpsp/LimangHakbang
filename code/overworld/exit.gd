extends Area3D

@export_file("*.tscn") var scene

var change_scene: bool = false

func _on_body_entered(body: Node3D) -> void:
	if not body is OverworldObject2D:
		change_scene = false
	else:
		change_scene = true

func _physics_process(_delta: float) -> void:
	pass
	if change_scene:
		get_tree().change_scene_to_file(scene)

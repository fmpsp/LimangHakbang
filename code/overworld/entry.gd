extends Area3D

@export_file("*.tscn") var scene
var door_entered : bool = false

func _on_body_entered(body: Node3D) -> void:
	
	print("yes")
	if not body is OverworldObject2D:
		door_entered = false
		return
	else:
		door_entered = true


func _on_body_exited(body: Node3D) -> void:
	door_entered = false


func _physics_process(delta: float) -> void:	
	if Input.is_action_pressed("overworld_up") and door_entered:
		get_tree().change_scene_to_file(scene)

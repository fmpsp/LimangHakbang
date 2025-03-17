extends Area3D

@export_file("*.tscn") var scene

func interact():
	await Fade.fade_out().finished
	get_tree().change_scene_to_file(scene)
	Fade.fade_in()

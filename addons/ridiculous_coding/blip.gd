@tool
extends Node2D

var destroy = false
var last_key = ""

func _ready():
	$AudioStreamPlayer.play()
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("default")
	$AnimationPlayer.play("default")
	$GPUParticles2D.emitting = true
	$Timer.start()
	$Label.text = last_key
	$Label.modulate = Color(randf_range(0,2), randf_range(0,2), randf_range(0,2))

func _on_Timer_timeout():
	if destroy:
		queue_free()

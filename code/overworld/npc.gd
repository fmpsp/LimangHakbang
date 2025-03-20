#Original code by minenice55
extends CharacterBody3D

@onready var animPlayer = get_node("Sprite3D/AnimationPlayer")

const FACING_TO_OFFSET = [
	Vector3(1,0,0),    #DOWN
	Vector3(0,0,1),    #LEFT
	Vector3(-1,0,0),   #UP
	Vector3(0,0,-1)    #RIGHT
]

enum FACING_VALUES {DOWN, LEFT, UP, RIGHT, INVALID}
const FACING_INVERSE = [FACING_VALUES.UP, FACING_VALUES.RIGHT, FACING_VALUES.DOWN, FACING_VALUES.LEFT, FACING_VALUES.INVALID]

@export var dirFacing = FACING_VALUES.DOWN

func _ready():
	animPlayer.current_animation = str("Idle", dirFacing)

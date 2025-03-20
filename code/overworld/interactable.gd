extends Area3D

signal dialogue_start

const FACING_TO_OFFSET = [
	Vector3(1,0,0),    #DOWN
	Vector3(0,0,1),    #LEFT
	Vector3(-1,0,0),   #UP
	Vector3(0,0,-1)    #RIGHT
]

enum FACING_VALUES {DOWN, LEFT, UP, RIGHT, INVALID}
const FACING_INVERSE = [FACING_VALUES.UP, FACING_VALUES.RIGHT, FACING_VALUES.DOWN, FACING_VALUES.LEFT, FACING_VALUES.INVALID]

@export var dialogue : DialogueResource
@export var character : CharacterBody3D
@export var player : CharacterBody3D

@onready var noticeUI = player.get_node("CanvasLayer/BoxContainer/noticeUI") as TextureRect
@onready var parent = get_parent_node_3d()
@onready var animation_player = parent.get_node("Sprite3D/AnimationPlayer") as AnimationPlayer

func interact():
	noticeUI.hide()
	if parent is CharacterBody3D:
		var position_difference : Vector3 = character.position - player.position
		var direction_to_face
		match position_difference:
			FACING_TO_OFFSET[FACING_VALUES.LEFT] * 2:
				direction_to_face = FACING_VALUES.LEFT
			FACING_TO_OFFSET[FACING_VALUES.UP] * 2:
				direction_to_face = FACING_VALUES.UP
			FACING_TO_OFFSET[FACING_VALUES.RIGHT] * 2:
				direction_to_face = FACING_VALUES.RIGHT
			FACING_TO_OFFSET[FACING_VALUES.DOWN] * 2:
				direction_to_face = FACING_VALUES.DOWN
		animation_player.current_animation = str("Idle", FACING_INVERSE[direction_to_face])
	else:
		DialogueManager.show_dialogue_balloon(dialogue)

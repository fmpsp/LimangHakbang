#Original code by minenice55
extends CharacterBody3D
class_name OverworldObject2D

var gridHelper = load("code/overworld/gridmapCollisionDef.gd")

@onready var parent = get_parent_node_3d()
@onready var world = parent.get_node("GridMap")
@onready var animPlayer = get_node("Sprite3D/AnimationPlayer")
@onready var floorCast = get_node("floorCast")
@onready var interactCast = get_node("interactCast")

const FACING_TO_OFFSET = [
	Vector3(1,0,0),    #DOWN
	Vector3(0,0,1),    #LEFT
	Vector3(-1,0,0),   #UP
	Vector3(0,0,-1)    #RIGHT
]

enum FACING_VALUES {DOWN, LEFT, UP, RIGHT, INVALID}
const FACING_INVERSE = [FACING_VALUES.UP, FACING_VALUES.RIGHT, FACING_VALUES.DOWN, FACING_VALUES.LEFT, FACING_VALUES.INVALID]

#last position in tile space
var posTileLast = Vector3(0, 0, 0)
#position in tile space
var posTile = Vector3(0, 0, 0)
#global velocity
var velTile = Vector3(0, 0, 0)
#current "floor" in the map (also Y position in tile space
var yLayer = 0

#object's current direction
var dirFacing = FACING_VALUES.DOWN
var lastDirFacing = dirFacing

const walkSpeed = 4
const runSpeed = walkSpeed*2
const quickTurnMargin = 0.25/3
#speed of movement in current direction
var moveVel = 0
var slopeSpeedMultiplier = 1

var moveBlocked = false

#counter til reached next tile (normalized)
var moveTimer = 0

#counter for the "quick turn"
var quickTurnTimer = 0

func _ready():
	animPlayer.current_animation = str("Idle", dirFacing)

#check for valid tiles to move to and
#if moving, and going uphill, slow the player down
func _process(delta):
	#start animation when moving
	
	if moveTimer > 0 and quickTurnTimer <= 0:
		if Input.is_action_pressed("overworld_run"):
			animPlayer.current_animation = str("Run", dirFacing)
		else:
			animPlayer.current_animation = str("Walk", dirFacing)
	else:
		#we would check if the next move is valid here
		if hasPlayerInvokedMove():
			
			if Input.is_action_pressed("overworld_up"):
				dirFacing = FACING_VALUES.UP
			elif Input.is_action_pressed("overworld_down"):
				dirFacing = FACING_VALUES.DOWN
			elif Input.is_action_pressed("overworld_left"):
				dirFacing = FACING_VALUES.LEFT
			elif Input.is_action_pressed("overworld_right"):
				dirFacing = FACING_VALUES.RIGHT
			
			if isFacingTileSolid():
				if not moveBlocked:
					#reset quickturntimer to greater than zero when action taken while facubg solid 
					quickTurnTimer = quickTurnMargin
					animPlayer.current_animation = str("Walk", dirFacing)
					#prevent player from moving into solids
					moveBlocked = true
			
			if hasPlayerJustInvokedMove():
				#quickturn code
				if dirFacing != lastDirFacing:
					quickTurnTimer = quickTurnMargin
					animPlayer.current_animation = str("Walk", dirFacing)
			#if moving
			if quickTurnTimer <= 0:
				if not isFacingTileSolid():
					#move to next tile in direction facing
					posTileLast = posTile
					posTile += FACING_TO_OFFSET[dirFacing]
					slopeSpeedMultiplier = 1
					
					#get facing tile type
					var celId = world.get_cell_item(Vector3i(posTile.x, posTile.y, posTile.z))
					#check if tile is a slope and move up y
					if world.mesh_library.collisionType[celId] == gridHelper.TYPES.SLOPE:
						posTile.y += 1
						slopeSpeedMultiplier = 0.7
					
					#store previous tile
					celId = world.get_cell_item(Vector3i(posTileLast.x, posTileLast.y - 1, posTileLast.z))
					
					#if moving back to that tile, check if it's a slope, then move down
					if gridHelper.ORTHO_TO_INDEX[dirFacing] == world.get_cell_item_orientation(Vector3i(posTileLast.x, posTileLast.y-1, posTileLast.z)) and world.mesh_library.collisionType[celId] == gridHelper.TYPES.SLOPE:
						posTile.y -= 1
						slopeSpeedMultiplier = 0.85
					
					moveTimer = 1
			
		else:
			moveBlocked = false
			#stop moving
			if quickTurnTimer <= 0:
				moveTimer = 0
				moveVel = 0
		#if not moving, stop moving, and play idle
		if moveTimer <= 0 and quickTurnTimer <= 0:
			moveTimer = 0
			moveVel = 0
			animPlayer.current_animation = str("Idle", dirFacing)
	
	moveTimer -= delta * moveVel/1 * slopeSpeedMultiplier
	quickTurnTimer -= delta
	lastDirFacing = dirFacing
	
	var cam = get_node("CameraTest")
	if Input.is_action_pressed("ui_up"):
		cam.position.x -= 2 * delta * 2
		cam.position.y -= 2 * delta * 2
		print(str(cam.position.x, ";", cam.position.y))
	if Input.is_action_pressed("ui_down"):
		cam.position.x += 2 * delta * 2
		cam.position.y += 2 * delta * 2
		print(str(cam.position.x, ";", cam.position.y))
	if Input.is_action_pressed("ui_accept"):
		cam.position.x = 9
		cam.position.y = 11
	
	#rotate raycast to match direction facing
	match dirFacing:
		FACING_VALUES.DOWN:
			rotateYAxis(interactCast, PI)
		FACING_VALUES.LEFT:
			rotateYAxis(interactCast, PI/2)
		FACING_VALUES.UP:
			rotateYAxis(interactCast, 0)
		FACING_VALUES.RIGHT:
			rotateYAxis(interactCast, -PI/2)
	var celId = world.get_cell_item(Vector3i(posTile.x, posTile.y, posTile.z))
	print(world.mesh_library.collisionType[celId])

func _physics_process(_delta):
	# USE A RAYCAST TO "SNAP" TO FLOOR POSITION INSTEAD OF LERPING TO ALLOW FOR ACCURATE COLLISION
	floorCast.force_raycast_update()
	position.y = floorCast.get_collision_point().y
	# if moving, change position to new position
	if moveTimer > 0 and quickTurnTimer <= 0:
		position.x = lerp(posTile.x, posTileLast.x, moveTimer) * world.cell_size.x
		position.z = lerp(posTile.z, posTileLast.z, moveTimer) * world.cell_size.z
		if Input.is_action_pressed("overworld_run"):
			moveVel = runSpeed
		else:
			moveVel = walkSpeed
	else:
		position.x = posTile.x*world.cell_size.x
		position.z = posTile.z*world.cell_size.z
	if %interactCast.is_colliding():
		var target = %interactCast.get_collider()
		if target.has_method("interact"):
			%interactText.show()
			if Input.is_action_just_pressed("interact"):
				target.interact()
	else:
		%interactText.hide()

func isFacingTileSolid():
	#check for walls
	var tileDefs = world.mesh_library
	
	var standingCel = world.get_cell_item(Vector3i(posTile.x, posTile.y - 1, posTile.z))
	var checkTile = posTile + FACING_TO_OFFSET[dirFacing]
	var celId = world.get_cell_item(Vector3i(checkTile.x, checkTile.y, checkTile.z))
	match tileDefs.collisionType[celId]:
		gridHelper.TYPES.INVALID:
			pass
		gridHelper.TYPES.SOLID:
			return true
		gridHelper.TYPES.SLOPE:
			#print(gridHelper.ORTHO_TO_INDEX[dirFacing])
			#print(world.get_cell_item_orientation(checkTile.x, checkTile.y, checkTile.z))
			if gridHelper.ORTHO_TO_INDEX[FACING_INVERSE[dirFacing]] != world.get_cell_item_orientation(Vector3i(checkTile.x, checkTile.y, checkTile.z)):
				return true
	
	celId = world.get_cell_item(Vector3i(checkTile.x, checkTile.y - 1, checkTile.z))
	var celOri = world.get_cell_item_orientation(Vector3i(checkTile.x, checkTile.y - 1, checkTile.z))
	var testOri = world.get_cell_item_orientation(Vector3i(posTile.x, posTile.y-1, posTile.z))
	if tileDefs.collisionType[standingCel] == gridHelper.TYPES.SLOPE:
		if tileDefs.collisionType[celId] == gridHelper.TYPES.SLOPE and testOri == celOri:
			return false
		if gridHelper.ORTHO_TO_INDEX[dirFacing] != testOri and gridHelper.ORTHO_TO_INDEX[FACING_INVERSE[dirFacing]] != testOri:
			return true
	if tileDefs.collisionType[celId] == gridHelper.TYPES.SLOPE and gridHelper.ORTHO_TO_INDEX[dirFacing] != celOri:
		if gridHelper.INDEX_IS_SLOPE[celOri]:
			return true
		return false
	var celIdForSlope = world.get_cell_item(Vector3i(checkTile.x, checkTile.y - 2, checkTile.z))
	if celId == -1:
		if tileDefs.collisionType[standingCel] == gridHelper.TYPES.SLOPE and gridHelper.ORTHO_TO_INDEX[dirFacing] == testOri and celIdForSlope != -1:
			return false
		else:
			return true
	return false

func hasPlayerInvokedMove():
	if Input.is_action_pressed("overworld_up") or Input.is_action_pressed("overworld_down") or Input.is_action_pressed("overworld_left") or Input.is_action_pressed("overworld_right"):
		return true
	return false
	
func hasPlayerJustInvokedMove():
	if (Input.is_action_just_pressed("overworld_up") or Input.is_action_just_pressed("overworld_down") or Input.is_action_just_pressed("overworld_left") or Input.is_action_just_pressed("overworld_right")) and quickTurnTimer <= 0 and moveTimer <= 0:
		return true
	return false

func rotateYAxis(object, rotation_amount):
	if object.rotation.y == rotation_amount:
		pass
	else:
		object.rotation.y = 0
		object.rotate_y(rotation_amount)

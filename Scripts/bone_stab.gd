extends Attack
class_name Bone_Stab

var point_index : int
var boneGap : float
var waitTime : float
var stayTime : float
var boneHeight : float
var xArea := 0.0

var attackWarning : Attack_Warning

enum states {STATE_WAIT, STATE_STAY, STATE_LEAVE}
var currentState : states


# Used by attack creators to customise attack
var rotationOffset : float = 0
var positionOffset := Vector2.ZERO
var customTransform := false
var point_position_percentage := 0.5
var boneSpeed : float = 750

var heightOffset : float = 0

var point_position : Vector2:
	get():
		return BC.CombatZone.point_coordinator(BC.CombatZone.points, point_index, point_position_percentage).rotated(BC.CombatZone.rotation) + BC.CombatZone.position
var point_rotation : float:
	get():
		return BC.CombatZone.get_point_position(point_index).angle_to_point(BC.CombatZone.next_point(BC.CombatZone.points, point_index)) \
		+ BC.CombatZone.rotation

var bonesArray : Array[StandardBone]

func _ready():
	
	# Defaults to the current CombatZone length if no value is given
	if xArea == 0:
		xArea = BC.CombatZone.get_point_length(BC.CombatZone.points, point_index)
	var boneX = -xArea/2
	while boneX <= xArea/2:
		var newBone : StandardBone = BC.BonePath.instantiate()
		newBone.BC = BC
		newBone.position = Vector2(boneX, 0)
		newBone.Height = 0
		newBone.change_pivot(Vector2(0, -newBone.Height/2))
		newBone.Direction = 0
		newBone.Speed = 0
		add_child(newBone)
		
		bonesArray.append(newBone)
		boneX += boneGap
	pass

func _process(delta):
	
	
	match currentState:
		states.STATE_WAIT:
			waitTime -= delta
			if waitTime <= 0:
				currentState = states.STATE_STAY
		states.STATE_STAY:
			var newOffset = heightOffset + (delta * boneSpeed)
			if newOffset < boneHeight:
				heightOffset = newOffset
			elif newOffset >= boneHeight:
				heightOffset = boneHeight
			stayTime -= delta
			if stayTime <= 0:
				currentState = states.STATE_LEAVE
		states.STATE_LEAVE:
			var newOffset = heightOffset - (delta * boneSpeed)
			if newOffset > 0:
				heightOffset = newOffset
			elif newOffset <= 0:
				heightOffset = 0
	
	# 15 is the thickness of a combatzone line, cutting it by half puts it to the edge away from the center
	var heightAdjustment = Vector2(0, -7.5).rotated(point_rotation)
	for bone in bonesArray:
		bone.Height = heightOffset
		bone.change_pivot(Vector2(0, -bone.Height/2))
	if not customTransform:
		rotation = deg_to_rad(rotationOffset) + point_rotation
		position = point_position + heightAdjustment + positionOffset

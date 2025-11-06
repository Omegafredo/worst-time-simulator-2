extends Attack
class_name Bone_Stab

var point_index : int
var boneGap : float
var waitTime : float
var stayTime : float
var boneHeight : float
var xArea := 0.0

enum states {STATE_WAIT, STATE_STAY, STATE_LEAVE}
var currentState : states

var rotationOffset : float = 0
var positionOffset := Vector2.ZERO
var heightOffset : float = 0

var point_position_percentage := 0.5

var point_position : Vector2:
	get():
		return BC.CombatZone.point_coordinator(BC.CombatZone.points, point_index, point_position_percentage).rotated(BC.CombatZone.rotation) + BC.CombatZone.position
var point_rotation : float:
	get():
		return BC.CombatZone.get_point_position(point_index).angle_to_point(BC.CombatZone.next_point(BC.CombatZone.points, point_index)) \
		+ BC.CombatZone.rotation

var bonesArray : Array[StandardBone]

func _ready():
	if xArea == 0:
		xArea = (BC.CombatZone.get_point_position(point_index) - BC.CombatZone.next_point(BC.CombatZone.points, point_index)).length()
	var boneX = -xArea/2
	while boneX <= xArea/2:
		var newBone : StandardBone = BC.BonePath.instantiate()
		newBone.BC = BC
		newBone.position = Vector2(boneX, 0)
		newBone.Height = 200
		newBone.change_pivot(Vector2(0, -newBone.Height/2))
		newBone.Direction = 0
		newBone.Speed = 0
		add_child(newBone)
		
		bonesArray.append(newBone)
		boneX += boneGap
	pass

func _process(delta):
	positionOffset = point_position
	
	
	match currentState:
		states.STATE_WAIT:
			waitTime -= delta
			if waitTime <= 0:
				currentState = states.STATE_STAY
		states.STATE_STAY:
			if heightOffset < boneHeight:
				heightOffset += delta * 1500
			elif heightOffset > boneHeight:
				heightOffset = boneHeight
			stayTime -= delta
			if stayTime <= 0:
				currentState = states.STATE_LEAVE
		states.STATE_LEAVE:
			if heightOffset > 0:
				heightOffset -= delta * 1500
			elif heightOffset < 0:
				heightOffset = 0
	
	positionOffset -= Vector2(0, heightOffset).rotated(deg_to_rad(point_rotation) + rotation)
	rotation = deg_to_rad(rotationOffset) + point_rotation
	position = positionOffset

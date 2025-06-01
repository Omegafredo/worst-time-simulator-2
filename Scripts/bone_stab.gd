extends Attack
class_name Bone_Stab

var point_index : int
var boneGap : float
var waitTime : float
var stayTime : float
var boneHeight : float

enum states {STATE_WAIT, STATE_STAY, STATE_LEAVE}
var currentState : states

var rotationOffset : float = 0
var positionOffset : Vector2 = Vector2.ZERO
var heightOffset : float = 0

var point_position : Vector2:
	get():
		return BC.CombatZone.point_coordinator(BC.CombatZone.points, point_index, 0.5).rotated(BC.CombatZone.rotation) + BC.CombatZone.position
var point_rotation : float:
	get():
		return deg_to_rad(BC.CombatZone.get_point_position(point_index).angle_to_point(BC.CombatZone.next_point(BC.CombatZone.points, point_index))) \
		+ BC.CombatZone.rotation_degrees

var bonesArray : Array[StandardBone]

func _ready():
	var boneX : float = -1920/2
	while boneX <= 1920/2:
		var newBone : StandardBone = BC.BonePath.instantiate()
		newBone.BC = BC
		newBone.position = Vector2(boneX, 0)
		newBone.Height = 200
		newBone.Direction = 0
		newBone.Speed = 0
		add_child(newBone)
		
		bonesArray.append(newBone)
		boneX += boneGap


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
	
	positionOffset -= Vector2(0, heightOffset)
	rotation_degrees = rotationOffset + point_rotation
	position = positionOffset.rotated(deg_to_rad(point_rotation) + rotation)	

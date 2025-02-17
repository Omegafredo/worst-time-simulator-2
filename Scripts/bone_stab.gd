extends Attack
class_name Bone_Stab

var boneGap : float
var waitTime : float
var stayTime : float
var boneHeight : float

enum states {STATE_WAIT, STATE_STAY, STATE_LEAVE}
var currentState : states

var rotationOffset : float
var positionOffset : Vector2
var heightOffset : float

var boxRotation : float:
	get():
		return BC.CombatZone.rotation
var boxSize : Rect2:
	get():
		return BC.CombatZone.BoxSize
		
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
	positionOffset = Vector2(0, boxSize.size.y / 2)
	
	
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
	rotation = rotationOffset + boxRotation
	position = Vector2(1920/2, boxSize.get_center().y) + positionOffset.rotated(boxRotation + rotation)	

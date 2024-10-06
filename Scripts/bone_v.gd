extends Node2D

const OGBoneBottomY = 16
const OGBoneMiddleHeight = 8
const OGBoneHitboxHeight = 24
var Height : float
var Speed : float
var Direction : float

var Damage : int = 1
var Karma : int = 2

@onready var BoneTop := $BoneTop
@onready var BoneMiddle := $BoneMiddle
@onready var BoneBottom := $BoneBottom
@onready var AttackHitbox := $BoneHitreg
@onready var CollisionShape := $BoneHitreg/CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	position = position + Vector2(Speed * delta, 0).rotated(deg_to_rad(Direction))
	
	BoneMiddle.scale.y = (OGBoneMiddleHeight + Height) / 8
	BoneBottom.position.y = OGBoneBottomY + Height
	
	CollisionShape.shape.set_size(Vector2(10, OGBoneHitboxHeight + Height))
	CollisionShape.position = Vector2(5, (OGBoneHitboxHeight + Height) / 2)
	
	

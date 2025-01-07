extends Attack

const OGBoneBottomY = 16
const OGBoneMiddleHeight = 8
const OGBoneHitboxHeight = 24
var Height : float
var Speed : float
var Direction : float

@onready var BoneTop := $BoneTop
@onready var BoneMiddle := $BoneMiddle
@onready var BoneBottom := $BoneBottom
@onready var CollisionShape := Hitbox.find_child("CollisionShape2D")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	
	position = position + Vector2(Speed * delta, 0).rotated(deg_to_rad(Direction))
	
	BoneMiddle.scale.y = (OGBoneMiddleHeight + Height) / 8
	BoneBottom.position.y = OGBoneBottomY + Height
	
	CollisionShape.shape.set_size(Vector2(10, OGBoneHitboxHeight + Height))
	CollisionShape.position = Vector2(5, (OGBoneHitboxHeight + Height) / 2)
	
	

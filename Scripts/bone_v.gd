extends Node2D

const OGBoneBottomY = 16
const OGBoneMiddleHeight = 8
const OGBoneHitboxHeight = 24
var Height : float
var Speed : float
var Direction : float

@onready var BoneTop := $BoneTop
@onready var BoneMiddle := $BoneMiddle
@onready var BoneBottom := $BoneBottom
@onready var BoneReg := $BoneHitreg

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var BoneHitbox := CollisionShape2D.new()
	var Shape := RectangleShape2D.new()
	BoneReg.add_child(BoneHitbox)
	BoneMiddle.scale.y = (OGBoneMiddleHeight + Height) / 8
	BoneBottom.position.y = OGBoneBottomY + Height
	
	Shape.set_size(Vector2(10, OGBoneHitboxHeight + Height))
	BoneHitbox.position = Vector2(5, (OGBoneHitboxHeight + Height) / 2)
	BoneHitbox.set_shape(Shape)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	position = position + Vector2(Speed * delta, 0).rotated(deg_to_rad(Direction))
	
	pass

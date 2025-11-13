extends Attack
class_name StandardBone

#const OGBoneBottomY = 16
#const OGBoneMiddleHeight = 8
#const OGBoneHitboxHeight = 24

var Height : float
var Speed : float
var Direction : float

#@onready var BoneTop := $BoneTop
#@onready var BoneMiddle := $BoneMiddle
#@onready var BoneBottom := $BoneBottom
@export var CollisionShape : CollisionShape2D
@export var BoneSprite : NinePatchSprite2D


func change_pivot(pivot : Vector2) -> void:
	BoneSprite.position = -pivot
	CollisionShape.position = -pivot

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	
	#position = position + Vector2(Speed * delta, 0).rotated(deg_to_rad(Direction))
	
	#BoneMiddle.scale.y = (OGBoneMiddleHeight + Height) / 8
	#BoneBottom.position.y = OGBoneBottomY + Height
	
	#CollisionShape.shape.set_size(Vector2(10, OGBoneHitboxHeight + Height))
	#CollisionShape.position = Vector2(5, (OGBoneHitboxHeight + Height) / 2)
	
	# Changes the margins to be smaller if the height is less than 16 (the combined value of the top and bottom margins)
	while BoneSprite.patch_margin_top + BoneSprite.patch_margin_bottom > max(Height, 0):
		BoneSprite.patch_margin_top = max(0, BoneSprite.patch_margin_top -1)
		BoneSprite.patch_margin_bottom = max(0, BoneSprite.patch_margin_bottom -1)
		
	while BoneSprite.patch_margin_top + BoneSprite.patch_margin_bottom < min(Height, 16):
		BoneSprite.patch_margin_top = min(8, BoneSprite.patch_margin_top +1)
		BoneSprite.patch_margin_bottom = min(8, BoneSprite.patch_margin_bottom +1)
	
	BoneSprite.size.y = Height
	CollisionShape.shape.size.y = Height
	
	position += Vector2(Speed*delta, 0).rotated(deg_to_rad(Direction))
	
	
	

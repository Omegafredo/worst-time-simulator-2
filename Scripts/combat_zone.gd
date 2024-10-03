extends Node2D

var Speed: float = 200.0

signal DoneMoving
var Moving := false

var BoxSize: Rect2

var Width: float:
	get():
		return BoxSize.size.x
var Height: float:
	get():
		return BoxSize.size.y
		
@onready var Mask := $"/root/Main Node/Battle Controller/CombatZoneCorner/Mask"

@onready var CboxTopLeft := $CboxTopLeft
@onready var CboxTopMiddle := $CboxTopMiddle
@onready var CboxTopRight := $CboxTopRight
@onready var CboxLeftMiddle := $CboxLeftMiddle
@onready var CboxRightMiddle := $CboxRightMiddle
@onready var CboxBottomLeft := $CboxBottomLeft
@onready var CboxBottomMiddle := $CboxBottomMiddle
@onready var CboxBottomRight := $CboxBottomRight

@onready var BottomHitBoxBody := $BottomHitboxBody
@onready var TopHitBoxBody := $TopHitboxBody
@onready var LeftHitBoxBody := $LeftHitboxBody
@onready var RightHitBoxBody := $RightHitboxBody

@onready var BottomHitBox := $BottomHitboxBody.get_child(0)
@onready var TopHitBox := $TopHitboxBody.get_child(0)
@onready var LeftHitBox := $LeftHitboxBody.get_child(0)
@onready var RightHitBox := $RightHitboxBody.get_child(0)

var CenterPos: Vector2:
	get():
		return BoxSize.get_center()

var TopLeftOffset: Vector2:
	get():
		#return Vector2((Width * -0.5) / scale.x, (Height * -0.5) / scale.x)
		return BoxSize.position

var TopMiddleOffset: Vector2:
	get():
		#return Vector2(TopLeftOffset.x + CornerSize.x, TopLeftOffset.y)
		return Vector2(TopLeftOffset.x + CornerSize.x * scale.x, TopLeftOffset.y)

var TopRightOffset: Vector2:
	get():
		#return Vector2((Width * 0.5) / scale.x - CornerSize.x, (Height * -0.5) / scale.x)
		return BoxSize.end - Vector2(CornerSize.x * 3, BoxSize.size.y)
		#return to_local(BoxSize.end).rotated(rotation)

var LeftMiddleOffset: Vector2:
	get():
		#return Vector2((Width * -0.5) / scale.x, ((Height * -0.5) / scale.x) + CornerSize.y)
		return Vector2(TopLeftOffset.x, TopLeftOffset.y + CornerSize.y * scale.x)

var RightMiddleOffset: Vector2:
	get():
		#return Vector2((Width * 0.5) / scale.x + 1 - CornerSize.x, ((Height * -0.5) / scale.x) + CornerSize.y)
		return Vector2(TopRightOffset.x + scale.x, TopRightOffset.y + CornerSize.y * scale.x)

var BottomLeftOffset: Vector2:
	get():
		#return Vector2((Width * -0.5) / scale.x, (Height * 0.5) / scale.x - CornerSize.y)
		return BoxSize.end - Vector2(BoxSize.size.x, CornerSize.y * 3)

var BottomMiddleOffset: Vector2:
	get():
		#return Vector2(((Width * -0.5) / scale.x) + CornerSize.x, (Height * 0.5) / scale.x + 1 - CornerSize.y)
		return Vector2(BottomLeftOffset.x + CornerSize.x * scale.x, BottomLeftOffset.y + scale.x)

var BottomRightOffset: Vector2:
	get():
		#return Vector2((Width * 0.5) / scale.x - CornerSize.x, (Height * 0.5) / scale.x - CornerSize.y)
		return BoxSize.end - CornerSize * 3

var BottomHitboxOffset: Vector2:
	get():
		#return Vector2(0, (Height * 0.5) / scale.x - CornerSize.y / 2 + 0.5)
		#return Vector2(BoxSize.get_center().x, BoxSize.end.y - CornerSize.y - 0.5)
		return CboxBottomLeft.position + Vector2((CboxBottomRight.position.x - CboxTopLeft.position.x) / 2 + CornerSize.x / 2, 2.5 + 1)


var TopHitboxOffset: Vector2:
	get():
		#return Vector2(0, (Height * -0.5) / scale.x + CornerSize.y / 2 - 0.5)
		#return CboxTopLeft.global_position + Vector2((CboxBottomRight.global_position.x - CboxTopLeft.global_position.x) / 2 + CornerSize.x * 1.5, CornerSize.y + 1)
		return CboxTopLeft.position + Vector2((CboxBottomRight.position.x - CboxTopLeft.position.x) / 2 + CornerSize.x / 2, 2.5)
		

var LeftHitboxOffset: Vector2:
	get():
		#return Vector2((Width * -0.5) / scale.x + CornerSize.y / 2 - 0.5, 0)
		#return Vector2(BoxSize.position.x + CornerSize.x + 1, BoxSize.get_center().y)
		return CboxTopLeft.position + Vector2(2.5, (CboxBottomRight.position.y - CboxTopLeft.position.y) / 2 + CornerSize.x / 2)

var RightHitboxOffset: Vector2:
	get():
		#return Vector2((Width * 0.5) / scale.x - CornerSize.y / 2 + 0.5, 0)
		#return Vector2(BoxSize.end.x - CornerSize.x - 1, BoxSize.get_center().y)
		return CboxTopRight.position + Vector2(2.5 + 1, (CboxBottomRight.position.y - CboxTopLeft.position.y) / 2 + CornerSize.x / 2)

var HorizontalScale: float:
	get():
		#return (Width - CornerSize.x * 6) / 15
		return (CboxBottomRight.position.x - CboxTopLeft.position.x) / 5

var VerticalScale: float:
	get():
		#return (Height - CornerSize.x * 6) / 15
		return (CboxBottomRight.position.y - CboxTopLeft.position.y) / 5

var HorizontalHitboxScale: float:
	get():
		#return Width / 3
		return CboxBottomRight.position.x - CboxTopLeft.position.x

var VerticalHitboxScale: float:
	get():
		#return Height / 3
		return CboxBottomRight.position.y - CboxTopLeft.position.y

const CornerSize := Vector2(6, 6)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Mask.global_transform = CboxTopLeft.global_transform
	Mask.texture.size = (CboxBottomRight.global_position.rotated(-rotation) - CboxTopLeft.global_position.rotated(-rotation)) / scale.x + CornerSize + Vector2(1, 1)
	
	#get_parent().global_position.x = move_toward(get_parent().global_position.x, BoxSize.position.x, scale.x * Speed * delta)
	#get_parent().global_position.y = move_toward(get_parent().global_position.y, BoxSize.position.y, scale.x * Speed * delta)
	
	
	#get_parent().global_position = BoxSize.position
	
	self.global_position.x = move_toward(global_position.x, CenterPos.x, scale.x * Speed * delta)
	self.global_position.y = move_toward(global_position.y, CenterPos.y, scale.x * Speed * delta)
	

	MoveObject(CboxTopLeft, TopLeftOffset, Speed * delta)
	MoveObject(CboxTopRight, TopRightOffset, Speed * delta)
	MoveObject(CboxBottomRight, BottomRightOffset, Speed * delta)
	MoveObject(CboxBottomLeft, BottomLeftOffset, Speed * delta)

	MoveObject(CboxTopMiddle, TopMiddleOffset, Speed * delta)
	#CboxTopMiddle.scale.x = move_toward(CboxTopMiddle.scale.x, HorizontalScale, (Speed * delta) / 2.5)
	CboxTopMiddle.scale.x = HorizontalScale
	MoveObject(CboxBottomMiddle, BottomMiddleOffset, Speed * delta)
	#CboxBottomMiddle.scale.x = move_toward(CboxBottomMiddle.scale.x, HorizontalScale, (Speed * delta) / 2.5)
	CboxBottomMiddle.scale.x = HorizontalScale
	MoveObject(CboxLeftMiddle, LeftMiddleOffset, Speed * delta)
	#CboxLeftMiddle.scale.y = move_toward(CboxLeftMiddle.scale.y, VerticalScale, (Speed * delta) / 2.5)
	CboxLeftMiddle.scale.y = VerticalScale
	MoveObject(CboxRightMiddle, RightMiddleOffset, Speed * delta)
	#CboxRightMiddle.scale.y = move_toward(CboxRightMiddle.scale.y, VerticalScale, (Speed * delta) / 2.5)
	CboxRightMiddle.scale.y = VerticalScale

	#MoveObject(BottomHitBoxBody, BottomHitboxOffset, Speed * delta)
	BottomHitBoxBody.position = BottomHitboxOffset
	#BottomHitBox.shape.size.x = move_toward(BottomHitBox.shape.size.x, HorizontalHitboxScale, (Speed * delta) * 2)
	BottomHitBox.shape.size.x = HorizontalHitboxScale
	#MoveObject(TopHitBoxBody, TopHitboxOffset, Speed * delta)
	TopHitBoxBody.position = TopHitboxOffset
	#TopHitBox.shape.size.x = move_toward(TopHitBox.shape.size.x, HorizontalHitboxScale, (Speed * delta) * 2)
	TopHitBox.shape.size.x = HorizontalHitboxScale
	#MoveObject(LeftHitBoxBody, LeftHitboxOffset, Speed * delta)
	LeftHitBoxBody.position = LeftHitboxOffset
	#LeftHitBox.shape.size.y = move_toward(LeftHitBox.shape.size.y, VerticalHitboxScale, (Speed * delta) * 2)
	LeftHitBox.shape.size.y = VerticalHitboxScale
	#MoveObject(RightHitBoxBody, RightHitboxOffset, Speed * delta)
	RightHitBoxBody.position = RightHitboxOffset
	#RightHitBox.shape.size.y = move_toward(RightHitBox.shape.size.y, VerticalHitboxScale, (Speed * delta) * 2)
	RightHitBox.shape.size.y = VerticalHitboxScale
	
	
	
	# If the top left corner, bottom right corner and the middle are moving, send a signal.
	if CboxTopLeft.position.move_toward(to_local(TopLeftOffset).rotated(rotation), 1) - CboxTopLeft.position == Vector2.ZERO \
			and CboxBottomRight.position.move_toward(to_local(BottomRightOffset).rotated(rotation), 1) - CboxBottomRight.position == Vector2.ZERO \
			and global_position.move_toward(CenterPos, 1) - global_position == Vector2.ZERO \
			and Moving:
		Moving = false
		DoneMoving.emit()


func SetPos() -> void:
	#get_parent().global_position = BoxSize.position
	
	self.global_position = CenterPos
	
	CboxTopLeft.position =  to_local(TopLeftOffset).rotated(rotation)
	CboxTopRight.position =  to_local(TopRightOffset).rotated(rotation) 
	CboxBottomRight.position =  to_local(BottomRightOffset).rotated(rotation)
	CboxBottomLeft.position =  to_local(BottomLeftOffset).rotated(rotation)

	CboxTopMiddle.position =  to_local(TopMiddleOffset).rotated(rotation) 
	CboxBottomMiddle.position =  to_local(BottomMiddleOffset).rotated(rotation)
	CboxLeftMiddle.position =  to_local(LeftMiddleOffset).rotated(rotation) 
	CboxRightMiddle.position =  to_local(RightMiddleOffset).rotated(rotation)

	CboxTopMiddle.scale.x = HorizontalScale
	CboxBottomMiddle.scale.x = HorizontalScale
	CboxLeftMiddle.scale.y = VerticalScale
	CboxRightMiddle.scale.y = VerticalScale

	BottomHitBoxBody.position =  to_local(BottomHitboxOffset).rotated(rotation)
	TopHitBoxBody.position =  to_local(TopHitboxOffset).rotated(rotation)
	LeftHitBoxBody.position =  to_local(LeftHitboxOffset).rotated(rotation)
	RightHitBoxBody.position =  to_local(RightHitboxOffset).rotated(rotation)

	BottomHitBox.shape.size.x = HorizontalHitboxScale
	TopHitBox.shape.size.x = HorizontalHitboxScale
	LeftHitBox.shape.size.y = VerticalHitboxScale
	RightHitBox.shape.size.y = VerticalHitboxScale
	


func MoveObject(MovableObject: Object, MoveTo: Vector2, DeltaSpeed: float) -> void:
	var originMovement = global_position.move_toward(CenterPos, 1) - global_position
	var currentMovement = MovableObject.position.move_toward(to_local(MoveTo).rotated(rotation), 1) - MovableObject.position
	
	var SetSpeed = Vector2(DeltaSpeed, DeltaSpeed)
	
	#if MovableObject == CboxTopLeft:
		#print(currentMovement.x, "|", originMovement.x)
	
	if (currentMovement.x < 0 and originMovement.x < 0) or (currentMovement.x > 0 and originMovement.x > 0):
		SetSpeed.x = DeltaSpeed * 0
	elif (currentMovement.x < 0 and originMovement.x > 0) or (currentMovement.x > 0 and originMovement.x < 0):
		SetSpeed.x = DeltaSpeed * 2
		
	if (currentMovement.y < 0 and originMovement.y < 0) or (currentMovement.y > 0 and originMovement.y > 0):
		SetSpeed.y = DeltaSpeed * 2
	elif (currentMovement.y < 0 and originMovement.y > 0) or (currentMovement.y > 0 and originMovement.y < 0):
		SetSpeed.y = DeltaSpeed * 0
		
	MovableObject.position.x = move_toward(MovableObject.position.x, to_local(MoveTo).rotated(rotation).x, SetSpeed.x)
	MovableObject.position.y = move_toward(MovableObject.position.y, to_local(MoveTo).rotated(rotation).y, SetSpeed.y)

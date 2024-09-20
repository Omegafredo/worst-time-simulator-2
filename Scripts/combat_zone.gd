extends Node2D

var Speed : float = 200.0

var TopLeft : Vector2
var BottomRight : Vector2

var Width : float:
	get():
		return BottomRight.x - TopLeft.x
var Height : float:
	get():
		return BottomRight.y - TopLeft.y

@onready var CboxTopLeft := $CboxTopLeft
@onready var CboxTopMiddle := $CboxTopMiddle
@onready var CboxTopRight := $CboxTopRight
@onready var CboxLeftMiddle := $CboxLeftMiddle
@onready var CboxRightMiddle := $CboxRightMiddle
@onready var CboxBottomLeft := $CboxBottomLeft
@onready var CboxBottomMiddle := $CboxBottomMiddle
@onready var CboxBottomRight :=  $CboxBottomRight

@onready var BottomHitBoxBody := $BottomHitboxBody
@onready var TopHitBoxBody := $TopHitboxBody
@onready var LeftHitBoxBody := $LeftHitboxBody
@onready var RightHitBoxBody := $RightHitboxBody

@onready var BottomHitBox := $BottomHitboxBody.get_child(0)
@onready var TopHitBox := $TopHitboxBody.get_child(0)
@onready var LeftHitBox := $LeftHitboxBody.get_child(0)
@onready var RightHitBox := $RightHitboxBody.get_child(0)


var CenterPos : Vector2:
	get():
		return Vector2(TopLeft.x + Width / 2, TopLeft.y + Height / 2)
var TopLeftOffset : Vector2:
	get():
		return Vector2((Width * -0.5) / scale.x, (Height * -0.5) / scale.x)
var TopMiddleOffset : Vector2:
	get():
		return Vector2(TopLeftOffset.x + CornerSize.x, TopLeftOffset.y)
var TopRightOffset : Vector2:
	get():
		return Vector2((Width * 0.5) / scale.x, (Height * -0.5) / scale.x)
var LeftMiddleOffset : Vector2:
	get():
		return Vector2((Width * -0.5) / scale.x, ((Height * -0.5) / scale.x) + CornerSize.y)
var RightMiddleOffset : Vector2:
	get():
		return Vector2((Width * 0.5) / scale.x + 1, ((Height * -0.5) / scale.x) + CornerSize.y)
var BottomLeftOffset : Vector2:
	get():
		return Vector2((Width * -0.5) / scale.x, (Height * 0.5) / scale.x)
var BottomMiddleOffset : Vector2:
	get():
		return Vector2(((Width * -0.5) / scale.x) + CornerSize.x, (Height * 0.5) / scale.x + 1)
var BottomRightOffset : Vector2:
	get():
		return Vector2((Width * 0.5) / scale.x, (Height * 0.5) / scale.x)

var BottomHitboxOffset : Vector2:
	get():
		return Vector2(CornerSize.x / 2, (Height * 0.5) / scale.x + CornerSize.y / 2 + 0.5)
var TopHitboxOffset : Vector2:
	get():
		return Vector2(CornerSize.x / 2, (Height * -0.5) / scale.x + CornerSize.y / 2 - 0.5)
var LeftHitboxOffset : Vector2:
	get():
		return Vector2((Width * -0.5) / scale.x + CornerSize.y / 2 - 0.5, CornerSize.y / 2)
var RightHitboxOffset : Vector2:
	get():
		return Vector2((Width * 0.5) / scale.x + CornerSize.y / 2 + 0.5, CornerSize.y / 2)

var HorizontalScale : float:
	get():
		return (Width - CornerSize.x * 3) / 15
var VerticalScale : float:
	get():
		return (Height - CornerSize.x * 3) / 15

var HorizontalHitboxScale : float:
	get():
		return (Width + CornerSize.x * 3) / 3
var VerticalHitboxScale : float:
	get():
		return (Height + CornerSize.x * 3) / 3

var CornerSize := Vector2(6, 6)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	self.global_position.x = move_toward(global_position.x, CenterPos.x, scale.x * Speed * delta)
	self.global_position.y = move_toward(global_position.y, CenterPos.y, scale.x * Speed * delta)
	
	MoveObject(CboxTopLeft, TopLeftOffset, Speed * delta)
	MoveObject(CboxTopRight, TopRightOffset, Speed * delta)
	MoveObject(CboxBottomRight, BottomRightOffset, Speed * delta)
	MoveObject(CboxBottomLeft, BottomLeftOffset, Speed * delta)
	
	MoveObject(CboxTopMiddle, TopMiddleOffset, Speed * delta)
	CboxTopMiddle.scale.x = move_toward(CboxTopMiddle.scale.x, HorizontalScale, (Speed * delta) / 2.5)
	MoveObject(CboxBottomMiddle, BottomMiddleOffset, Speed * delta)
	CboxBottomMiddle.scale.x = move_toward(CboxBottomMiddle.scale.x, HorizontalScale, (Speed * delta) / 2.5)
	MoveObject(CboxLeftMiddle, LeftMiddleOffset, Speed * delta)
	CboxLeftMiddle.scale.y = move_toward(CboxLeftMiddle.scale.y, VerticalScale, (Speed * delta) / 2.5)
	MoveObject(CboxRightMiddle, RightMiddleOffset, Speed * delta)
	CboxRightMiddle.scale.y = move_toward(CboxRightMiddle.scale.y, VerticalScale, (Speed * delta) / 2.5)
	
	MoveObject(BottomHitBoxBody, BottomHitboxOffset, Speed * delta)
	BottomHitBox.shape.size.x = move_toward(BottomHitBox.shape.size.x, HorizontalHitboxScale, (Speed * delta) * 2)
	MoveObject(TopHitBoxBody, TopHitboxOffset, Speed * delta)
	TopHitBox.shape.size.x = move_toward(TopHitBox.shape.size.x, HorizontalHitboxScale, (Speed * delta) * 2)
	MoveObject(LeftHitBoxBody, LeftHitboxOffset, Speed * delta)
	LeftHitBox.shape.size.y = move_toward(LeftHitBox.shape.size.y, VerticalHitboxScale, (Speed * delta) * 2)
	MoveObject(RightHitBoxBody, RightHitboxOffset, Speed * delta)
	RightHitBox.shape.size.y = move_toward(RightHitBox.shape.size.y, VerticalHitboxScale, (Speed * delta) * 2) 
	
	
func SetPos() -> void:
	
	self.global_position = CenterPos
	CboxTopLeft.position = TopLeftOffset
	CboxTopRight.position = TopRightOffset
	CboxBottomRight.position = BottomRightOffset
	CboxBottomLeft.position = BottomLeftOffset
	
	CboxTopMiddle.position = TopMiddleOffset
	CboxBottomMiddle.position = BottomMiddleOffset
	CboxLeftMiddle.position = LeftMiddleOffset
	CboxRightMiddle.position = RightMiddleOffset
	
	CboxTopMiddle.scale.x = HorizontalScale
	CboxBottomMiddle.scale.x = HorizontalScale
	CboxLeftMiddle.scale.y = VerticalScale
	CboxRightMiddle.scale.y = VerticalScale
	
	BottomHitBoxBody.position = BottomHitboxOffset
	TopHitBoxBody.position = TopHitboxOffset
	LeftHitBoxBody.position = LeftHitboxOffset
	RightHitBoxBody.position = RightHitboxOffset
	
	BottomHitBox.shape.size.x = HorizontalHitboxScale
	TopHitBox.shape.size.x = HorizontalHitboxScale
	LeftHitBox.shape.size.y = VerticalHitboxScale
	RightHitBox.shape.size.y = VerticalHitboxScale
	


func MoveObject(MovableObject : Object, MoveTo : Vector2, DeltaSpeed : float) -> void:
	MovableObject.position.x = move_toward(MovableObject.position.x, MoveTo.x, DeltaSpeed)
	MovableObject.position.y = move_toward(MovableObject.position.y, MoveTo.y, DeltaSpeed)

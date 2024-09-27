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
		
@onready var Mask := $"/root/Main Node/Battle Controller/CombatZone/Mask"

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
		return BoxSize.position + (BoxSize.size / 2) - Vector2(CornerSize.x * 3, 0)

var TopLeftOffset: Vector2:
	get():
		return Vector2((Width * -0.5) / scale.x, (Height * -0.5) / scale.x)

var TopMiddleOffset: Vector2:
	get():
		return Vector2(TopLeftOffset.x + CornerSize.x, TopLeftOffset.y)

var TopRightOffset: Vector2:
	get():
		return Vector2((Width * 0.5) / scale.x - CornerSize.x, (Height * -0.5) / scale.x)

var LeftMiddleOffset: Vector2:
	get():
		return Vector2((Width * -0.5) / scale.x, ((Height * -0.5) / scale.x) + CornerSize.y)

var RightMiddleOffset: Vector2:
	get():
		return Vector2((Width * 0.5) / scale.x + 1 - CornerSize.x, ((Height * -0.5) / scale.x) + CornerSize.y)

var BottomLeftOffset: Vector2:
	get():
		return Vector2((Width * -0.5) / scale.x, (Height * 0.5) / scale.x - CornerSize.y)

var BottomMiddleOffset: Vector2:
	get():
		return Vector2(((Width * -0.5) / scale.x) + CornerSize.x, (Height * 0.5) / scale.x + 1 - CornerSize.y)

var BottomRightOffset: Vector2:
	get():
		return Vector2((Width * 0.5) / scale.x - CornerSize.x, (Height * 0.5) / scale.x - CornerSize.y)

var BottomHitboxOffset: Vector2:
	get():
		return Vector2(0, (Height * 0.5) / scale.x - CornerSize.y / 2 + 0.5)

var TopHitboxOffset: Vector2:
	get():
		return Vector2(0, (Height * -0.5) / scale.x + CornerSize.y / 2 - 0.5)

var LeftHitboxOffset: Vector2:
	get():
		return Vector2((Width * -0.5) / scale.x + CornerSize.y / 2 - 0.5, 0)

var RightHitboxOffset: Vector2:
	get():
		return Vector2((Width * 0.5) / scale.x - CornerSize.y / 2 + 0.5, 0)

var HorizontalScale: float:
	get():
		return (Width - CornerSize.x * 6) / 15

var VerticalScale: float:
	get():
		return (Height - CornerSize.x * 6) / 15

var HorizontalHitboxScale: float:
	get():
		return Width / 3

var VerticalHitboxScale: float:
	get():
		return Height / 3

const CornerSize := Vector2(6, 6)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Mask.position = CboxTopLeft.position
	Mask.texture.size = CboxBottomRight.position + abs(CboxTopLeft.position) + CornerSize 
	
	get_parent().global_position.x = move_toward(get_parent().global_position.x, BoxSize.position.x, scale.x * Speed * delta)
	get_parent().global_position.y = move_toward(get_parent().global_position.y, BoxSize.position.y, scale.x * Speed * delta)
	
	#get_parent().global_position = BoxSize.position
	
	#self.global_position.x = move_toward(global_position.x, CenterPos.x, scale.x * Speed * delta)
	#self.global_position.y = move_toward(global_position.y, CenterPos.y, scale.x * Speed * delta)
	
	self.position = abs(CboxTopLeft.position) * scale.x
	

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
	
	
	# Check if the box has reached it's destination
	if CboxTopLeft.position == TopLeftOffset and CboxBottomRight.position == BottomRightOffset and Moving:
		Moving = false
		DoneMoving.emit()


func SetPos() -> void:
	get_parent().global_position = BoxSize.position
	
	self.position = abs(CboxTopLeft.position) * scale.x
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


func MoveObject(MovableObject: Object, MoveTo: Vector2, DeltaSpeed: float) -> void:
	MovableObject.position.x = move_toward(MovableObject.position.x, MoveTo.x, DeltaSpeed)
	MovableObject.position.y = move_toward(MovableObject.position.y, MoveTo.y, DeltaSpeed)

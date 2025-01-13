extends Attack

@export var UpperPlatform : NinePatchSprite2D
@export var LowerPlatform : NinePatchSprite2D
@export var CS : CollisionShape2D


var Width : float:
	set(w):
		Width = w
		UpperPlatform.size.x = w
		LowerPlatform.size.x = w
		CS.shape.size.x = w
		
var Speed : float
var Direction : float

func _process(delta: float) -> void:
	super(delta)
	
	position = position + Vector2(Speed * delta, 0).rotated(deg_to_rad(Direction))

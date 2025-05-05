extends Line2D

var speed: float = 300.0

var moveToPoints : Array[Vector2]

signal done_moving

func simpleMove(BoxPos : Rect2) -> void:
	moveToPoints = [BoxPos.position, Vector2(BoxPos.end.x, BoxPos.position.y), BoxPos.end, Vector2(BoxPos.position.x, BoxPos.end.y)]

# Called when the node enters the scene tree for the first time.
func _ready():
	simpleMove(Rect2(800, 720, 400, 432))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var oldPosition := position
	
	var CenterPos : Vector2
	var MoveToCenterPos : Vector2
	
	var TopLeft : Vector2 = Vector2.INF
	var BottomRight : Vector2 = -Vector2.INF
	
	var MTTopLeft : Vector2 = Vector2.INF
	var MTBottomRight : Vector2 = -Vector2.INF
	
	for point in points:
		TopLeft = TopLeft.min(point)
		BottomRight = BottomRight.max(point)
		
	for point in moveToPoints:
		MTTopLeft = MTTopLeft.min(point)
		MTBottomRight = MTBottomRight.max(point)
	
	
	CenterPos = TopLeft + BottomRight
	MoveToCenterPos = (MTTopLeft + MTBottomRight)/2
	
	var Movement = position - position.move_toward(MoveToCenterPos, speed/2 * delta)
	position -= Movement
	
	var i : int = 0
	for point in points:
		set_point_position(i, point.move_toward(moveToPoints[i] - position, speed * delta - Movement.length()))
		i += 1
	
	
	

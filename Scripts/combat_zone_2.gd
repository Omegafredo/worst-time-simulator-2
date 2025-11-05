extends Line2D
class_name CombatZoneV2

var speed: float = 300.0


@onready var collision: CollisionPolygon2D = $AnimatableBody2D/CollisionPolygon2D
@export var mask : Polygon2D

var move_to_points : Array[Vector2]


var CenterPos : Vector2:
	get():
		var TopLeft : Vector2 = Vector2.INF
		var BottomRight : Vector2 = -Vector2.INF
		
		
		for point in points:
			TopLeft = TopLeft.min(point)
			BottomRight = BottomRight.max(point)
			
	
	
		return TopLeft + BottomRight
		
var MoveToCenterPos : Vector2:
	get():
		
		var MTTopLeft : Vector2 = Vector2.INF
		var MTBottomRight : Vector2 = -Vector2.INF
			
		for point in move_to_points:
			MTTopLeft = MTTopLeft.min(point)
			MTBottomRight = MTBottomRight.max(point)
		
		
		return (MTTopLeft + MTBottomRight)/2

signal done_moving

## Sets the box's destination to be the Rect2 coordinates.
## Forces it into a square if it already isn't, adding or removing points to do so.
func simple_move(BoxPos : Rect2) -> void:
	move_to_points = [BoxPos.position, Vector2(BoxPos.end.x, BoxPos.position.y), BoxPos.end, Vector2(BoxPos.position.x, BoxPos.end.y)]
	while points.size() != 4:
		if points.size() < 4:
			add_point(get_point_position(-1) if not null else position)
		else:
			remove_point(-1)
			
## Moves the box relatively in a direction without changing its shape.
func relative_move(moveDir : Vector2) -> void:
	for point in move_to_points:
		point += moveDir

## Instantly moves box to its destination.
func instant_move() -> void:
	position = MoveToCenterPos
	var i : int = 0
	for point in points:
		set_point_position(i, move_to_points[i] - position)
		i += 1
	

# Called when the node enters the scene tree for the first time.
func _ready():
	#simple_move(Rect2(900, 820, 200, 232))
	pass # Replace with function body.

## Returns the next point after [param index], looping to the start if at the end of the array.
func next_point(pointArray : Array[Vector2], index) -> Vector2:
	return pointArray[index + 1 if index < pointArray.size() - 1 else 0]
	
## Returns the position between the [param index] point and the next in an [param modifyArray].[br]
## The [param percentage_point] chooses where between the two points to get, going from 0 to 1.
func point_coordinator(modifyArray : Array[Vector2], index : int, percentage_point : float) -> Vector2:
	return modifyArray[index].lerp(next_point(modifyArray, index), percentage_point)
	
## Removes a point at a certain index
func point_remover(index : int) -> void:
	move_to_points.remove_at(index)
	remove_point(index)

## Adds a point after the specified [param index].[br]
## The position of the new point is determined by [param percentage_point] going from the [param index] point to the next point, going from 0 to 1.
func add_new_point(index : int, percentage_point : float) -> void:
	
	move_to_points.insert(index, point_coordinator(move_to_points, index, percentage_point))
	add_point(point_coordinator(points, index, percentage_point), index)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var oldPosition := position
	
	var Movement = position - position.move_toward(MoveToCenterPos, speed/2 * delta)
	position -= Movement
	
	var i : int = 0
	for point in points:
		# Move seperately for x and y coordinates
		var MovementFrame := Vector2(move_toward(point.x, move_to_points[i].x - position.x, (speed - Movement.x) * delta), \
									move_toward(point.y, move_to_points[i].y - position.y, (speed - Movement.y) * delta))
		
		set_point_position(i, MovementFrame)
		#set_point_position(i, point.move_toward(move_to_points[i] - position, speed * delta - Movement.y))
		i += 1
		
	var TopLeftPoints : PackedVector2Array
	var BottomRightPoints : PackedVector2Array
	
	var checkedPoints : PackedVector2Array = points
	
	checkedPoints.append(points[0])
	
	i = 0
	for point in checkedPoints:
		
		var nextPoint : Vector2 = next_point(checkedPoints, i)
		var direction : float = point.angle_to_point(nextPoint)
		var offset := Vector2.ONE.rotated(direction) * width/2
		
		TopLeftPoints.append(point - offset)
		BottomRightPoints.append(point + offset)
		
		TopLeftPoints.append(nextPoint - offset)
		BottomRightPoints.append(nextPoint + offset)
		
		i += 1
	
	
	#TopLeftPoints.append(points[0] - Vector2.ONE * width)
	#BottomRightPoints.append(points[0] - Vector2.ONE * width)
	
	BottomRightPoints.reverse()
	
	collision.polygon = TopLeftPoints + BottomRightPoints
	
	mask.polygon = points
	
	
	

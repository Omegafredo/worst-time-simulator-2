extends Attack
class_name Attack_Warning

@export var Sprite : NinePatchSprite2D
@export var _timer : Timer

var _pivotPoint : Vector2 = Vector2.ZERO

var size : Vector2:
	get():
		return Sprite.size
	set(x):
		Sprite.size = x
		_update_pivot()

func set_color(colorState : int) -> void:
	super(colorState)
	
	# Changes the color to be red instead of white when normal colors are used.
	if color == 0:
		modulate = Color.from_rgba8(143, 47, 47)
	

func disappear_timer(time : float) -> void:
	_timer.start(time)


func disappear() -> void:
	queue_free()

func set_size(size : Vector2) -> void:
	Sprite.set_size(size/3)
	_update_pivot()

func set_pivot(pivot : Vector2) -> void:
	_pivotPoint = pivot
	_update_pivot()

func _update_pivot() -> void:
	Sprite.position = Sprite.size * (-_pivotPoint * 3)

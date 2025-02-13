extends Label
class_name SettingSelection

const Active : Color = Color(1, 1, 0, 1)
const Default : Color = Color(1, 1, 1, 1)
const Deactive : Color = Color(0.5, 0.5, 0.5, 1)

var CurrentColor : Color = Default
var ActiveState : bool = false
@export var DeactiveState : bool = false

signal activated

func _ready() -> void:
	UpdateColor()

func Update() -> void:
	UpdateColor()

func UpdateColor() -> void:
	if DeactiveState:
		CurrentColor = Deactive
	modulate = Color(CurrentColor, modulate.a)

extends Label
class_name SettingSelection

const Active : Color = Color(1, 1, 0, 1)
const Default : Color = Color(1, 1, 1, 1)
const Deactive : Color = Color(0.7, 0.7, 0.7, 1)

var CurrentColor : Color = Default
var ActiveState : bool = false
var DeactiveState : bool = false

signal activated

func Update() -> void:
	
	if DeactiveState:
		CurrentColor = Deactive
	modulate = Color(CurrentColor, modulate.a)
	

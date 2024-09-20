extends Label
class_name SettingSelection

var Original_Text : String

const Active : Color = Color(1, 1, 0, 1)
const Default : Color = Color(1, 1, 1, 1)
const Deactive : Color = Color(0.7, 0.7, 0.7, 1)

@export var SideOption := false
@export var ClampedMin : float
@export var ClampedMax : float
@export var LinkedProperty : String
@export var Inverted : bool


var CurrentColor : Color = Default
var ActiveState : bool = false
var DeactiveState : bool = false

func _ready() -> void:
	Original_Text = text
	

func Update() -> void:
	if !LinkedProperty.is_empty():
		if SideOption:
			text = str(Original_Text, " : ", Globals.get(LinkedProperty))
		else:
			if Inverted:
				ActiveState = !Globals.get(LinkedProperty)
			else:
				ActiveState = Globals.get(LinkedProperty)
			
	if ActiveState:
		CurrentColor = Active
	else:
		CurrentColor = Default
	if DeactiveState:
		CurrentColor = Deactive
	modulate = CurrentColor
	
func CheckIfClamp(Direction : int) -> bool:
	if ClampedMin != 0 and ClampedMax != 0:
		if Globals.get(LinkedProperty) <= ClampedMin and Direction <= 0:
			return false
		if Globals.get(LinkedProperty) >= ClampedMax and Direction >= 0:
			return false
		return true
	else:
		return true

func LowerIfNearEdge(Direction : int) -> int:
	if Globals.get(LinkedProperty) + Direction < ClampedMin:
		return Direction + 1
	if Globals.get(LinkedProperty) + Direction > ClampedMax:
		return Direction - 1
	return Direction

extends Label
class_name SettingSelection

var Original_Text : String

const Active : Color = Color(1, 1, 0, 1)
const Default : Color = Color(1, 1, 1, 1)
const Deactive : Color = Color(0.7, 0.7, 0.7, 1)

@export var SideOption := false
@export var DirMultiplier : float = 1
@export var MultiplyShown : float = 1
@export var MenuChange : Menu
@export var ClampedMin : float
@export var ClampedMax : float
@export var PropertyObject : NodePath = "/root/Globals"
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
			text = str(Original_Text, ": ", snappedf(Globals.get(LinkedProperty), 0.01) * MultiplyShown)
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
	modulate = Color(CurrentColor, modulate.a)
	
func CheckIfClamp(Direction : float) -> bool:
	if ClampedMin != 0 or ClampedMax != 0:
		if get_node(PropertyObject).get(LinkedProperty) <= ClampedMin and Direction <= 0:
			return false
		if get_node(PropertyObject).get(LinkedProperty) >= ClampedMax and Direction >= 0:
			return false
	return true

func LowerIfNearEdge(Direction : float) -> float:
	if ClampedMin != 0 or ClampedMax != 0:
		if get_node(PropertyObject).get(LinkedProperty) + Direction < ClampedMin:
			return -abs(ClampedMin - get_node(PropertyObject).get(LinkedProperty))
		if get_node(PropertyObject).get(LinkedProperty) + Direction > ClampedMax:
			return abs(ClampedMax - get_node(PropertyObject).get(LinkedProperty))
	return Direction

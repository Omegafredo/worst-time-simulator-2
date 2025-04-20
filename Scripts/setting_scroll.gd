extends SettingSelection
class_name SettingScroll

var Original_Text : String = text

@export var DirMultiplier : float = 1
@export var MultiplyShown : float = 1
@export var ClampedMin : float
@export var ClampedMax : float
@export var PropertyObject : NodePath = "/root/Globals"
@export var LinkedProperty : String

func _ready() -> void:
	if LinkedProperty == "MaxHP":
		@warning_ignore("narrowing_conversion")
		Globals.MaxHP = clampi(Globals.MaxHP, ClampedMin, ClampedMax)

func Update() -> void:
	text = str(Original_Text, ": ", int(snappedf(Globals.get(LinkedProperty), 0.01) * MultiplyShown))
	super()

func CheckIfClamp(Direction : float) -> bool:
	if ClampsSet():
		if get_node(PropertyObject).get(LinkedProperty) <= ClampedMin and Direction <= 0:
			return false
		if get_node(PropertyObject).get(LinkedProperty) >= ClampedMax and Direction >= 0:
			return false
	return true

func LowerIfNearEdge(Direction : float) -> float:
	if ClampsSet():
		if get_node(PropertyObject).get(LinkedProperty) + Direction < ClampedMin:
			return -abs(ClampedMin - get_node(PropertyObject).get(LinkedProperty))
		if get_node(PropertyObject).get(LinkedProperty) + Direction > ClampedMax:
			return abs(ClampedMax - get_node(PropertyObject).get(LinkedProperty))
	return Direction

func ClampsSet() -> bool:
	return ClampedMin != 0 or ClampedMax != 0

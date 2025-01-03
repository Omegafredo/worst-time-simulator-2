extends SettingSelection
class_name SettingToggler

@export var PropertyObject : NodePath = "/root/Globals"
@export var LinkedProperty : String
@export var Inverted : bool

func Update() -> void:
	
	if Inverted:
		ActiveState = !Globals.get(LinkedProperty)
	else:
		ActiveState = Globals.get(LinkedProperty)
	
	if ActiveState:
		CurrentColor = Active
	else:
		CurrentColor = Default
		
	super()

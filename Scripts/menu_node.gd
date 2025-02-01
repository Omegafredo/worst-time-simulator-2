@tool
extends Node2D
class_name Menu

var HideAfter : bool = false
@export var CustomMenu := false
@export var HeaderPos : Marker2D
@export var Animatables : Array[Node]

signal entered(HeaderPos, Animatables)
signal exited

func Enter(Header : SettingMenuChanger) -> void:
	entered.emit(HeaderPos, Header, Animatables)
	
func Exit() -> void:
	exited.emit(Animatables)

func _process(_delta):
	if Engine.is_editor_hint():
		if !CustomMenu:
			var Total_Gap : float = 0
			for Option in get_children():
				if Option is SettingSelection:
					Option.position.y = Total_Gap 
					Total_Gap += Option.size.y + 4
	else:
		if HideAfter:
			for child in get_children():
				if child.modulate.a == 0:
					hide()

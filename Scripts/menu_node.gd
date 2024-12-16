@tool
extends Node2D
class_name Menu

var HideAfter : bool = false

func _process(_delta):
	if Engine.is_editor_hint():
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

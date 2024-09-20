@tool
extends Node2D
class_name Menu



func _process(_delta):
	if Engine.is_editor_hint():
		var Total_Gap : float = 0
		for Option in get_children():
			Option.position.y = Total_Gap 
			Total_Gap += Option.size.y + 4
		

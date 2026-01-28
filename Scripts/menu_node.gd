@tool
extends Node2D
class_name Menu

enum STATES {
	off,
	entering,
	on,
	exiting
}

var currentState : int = STATES.off
var HideAfter : bool = false
@export var CustomMenu := false
@export var HeaderPos : Marker2D
@export var Animatables : Array[Node]

signal entered(HeaderPos, Header, Animatables)
signal exited(Animatables)

func Enter(Header : SettingMenuChanger) -> void:
	entered.emit(HeaderPos, Header, Animatables)
	currentState = STATES.entering
	
func Exit() -> void:
	exited.emit(Animatables)
	currentState = STATES.exiting

func _process(_delta):
	if Engine.is_editor_hint():
		if !CustomMenu:
			var Total_Gap : float = 0
			for Option in get_children():
				if Option is SettingSelection:
					Option.position.y = Total_Gap 
					Total_Gap += Option.size.y + 4
	# Don't remember what HideAfter is for, disabling it doesn't break anything so I guess I'll just leave it like this.
	#else:
		#if HideAfter:
			#for child in get_children():
				#if child.modulate.a == 0:
					#hide()

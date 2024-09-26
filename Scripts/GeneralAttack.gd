extends Node2D
class_name Attack

var Masked : bool = false:
	set(d):
		if d:
			reparent(MaskedNode)
		else:
			reparent(AttacksNode)
		Masked = d
		print(MaskedNode)
		print(AttacksNode)
@onready var MaskedNode := $"/root/Main Node/Battle Controller/CombatZone/Mask/Attacks"
@onready var AttacksNode := $"/root/Main Node/Battle Controller/Attacks"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

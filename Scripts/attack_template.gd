extends Node

@onready var BC = %"Battle Controller"
@onready var AttackTurns = BC.AttackTurns
@onready var AmountTurns = BC.AmountTurns

func AttackStart() -> void:
	match AttackTurns:
		0:
			Attack1()
		1:
			Attack2()
		2:
			Attack3()

func Attack1() -> void:
	pass
	
func Attack2() -> void:
	pass
	
func Attack3() -> void:
	pass

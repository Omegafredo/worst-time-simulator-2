extends Node

@onready var BC = %"Battle Controller"
# Usable variables:
# BC.AttackTurns : Amount of times the player has attacked Sans.
# BC.AmountTurns : Amount of turns have passed, including healing, acting etc.
		

func AttackStart() -> void:
	match BC.AttackTurns:
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

extends Node

var BC : BattleController
# Usable variables:
# BC.AttackTurns : Amount of times the player has attacked Sans.
# BC.AmountTurns : Amount of turns have passed, including healing, acting etc.


func LoadVariables() -> void:
	BC = get_parent()

func AttackStart() -> void:
	match BC.AttackTurns:
		0:
			Attack1()
		1:
			Attack2()
		2:
			Attack3()

func Attack1() -> void:
	#BC.SoulMode(1)
	#BC.Bone(Vector2(1200, 1000),50,180,70,true)
	#BC.Platform(Vector2(1200, 1000),50,180,70,true)
	#BC.CombatBox(Rect2(400, 720, 1400, 1152))
	BC.ReturnToMenu()
	pass
	
func Attack2() -> void:
	pass
	
func Attack3() -> void:
	pass

extends Node

var BC : BattleController
# Usable variables:
# BC.AttackTurns : Amount of times the player has attacked Sans.
# BC.AmountTurns : Amount of turns have passed, including healing, acting etc.


func LoadVariables() -> void:
	BC = get_parent()
	
	var CPie = Globals.CPie
	var CNoodles = Globals.CNoodles
	var CSteak = Globals.CSteak
	var CHero = Globals.CHero
	
	# Custom Item:
	#var CSnow := FoodItem.new()
	#CSnow.FullName = "Snowman Piece"
	#CSnow.Name = "SnowPiece"
	#CSnow.AdditionalDescription = ["* Another set of text", "* Yet another set of text\n[indent]This is on another line"]
	#CSnow.Health = 45
	
	
	# Uncomment if you want to modify the default inventory, otherwise the default will be used
	#Globals.CurrentItems = [CPie, CNoodles, CSteak, CHero, CHero, CHero, CHero, CHero]

func ActMenu() -> void:
	# Creates the Check action and connects it to the CheckAction() function
	var Check = BC.CreateMenuInput("Check")
	Check.activated.connect(CheckAction)
	
	# Custom act action
	#var Taunt = BC.CreateMenuInput("Taunt")
	#Taunt.actiavted.connect(YourFunction)
	
func CheckAction() -> void:
	BC.InitiateDescription(["* SANS 1 ATK 1 DEF\n* The easiest enemy...\n* But something feels different.", "[color=red]* But we've killed him before,\n[indent]we can do it again."])

# MercyMenu() and ActMenu() can be commented or deleted if you do not want to change them

#func MercyMenu() -> void:
	#BC.CreateMenuInput("Spare")
	#
	## Custom mercy action
	##var Flee = BC.CreateMenuInput("Flee")
	##Flee.activated.connect(YourFunction)
	
func TurnDescription() -> void:
	match BC.AttackTurns:
		0:
			BC.MenuText.setText("* This is the turn text for turn 1.")
		1:
			BC.MenuText.setText("* This is how you split\n[indent]text onto\nthree lines.")
		2:
			# Conditional turn text
			if Globals.HP <= 40:
				BC.MenuText.setText("* You feel like you're going to die.")
			else:
				BC.MenuText.setText("* Just another example")
		_:
			# Non turn-specific text:
			if Globals.KR >= 20:
				BC.MenuText.setText("* KARMA coursing through your\n[indent]veins.")
			elif Globals.KR >= 10:
				BC.MenuText.setText("* You felt your sins weighing\n[indent]on your neck.")
			elif Globals.KR >= 0:
				BC.MenuText.setText("* You felt your sins crawling\n[indent]on your back.")
			elif BC.AttackTurns == 3: # If you want an attack turn text to have low priority
				BC.MenuText.setText("* You feel as if something\n[indent]bad is about to happen.")
			else: # Remember to have a fail-safe
				BC.MenuText.setText("* Keep Attacking.")


func AttackStart() -> void:
	match BC.AttackTurns:
		0:
			Attack1()
		1:
			Attack2()
		2:
			Attack3()

func Attack1() -> void:
	BC.GasterBlaster(0, Vector2(0, 0), Vector2(300, 900), 0, 0, 2)
	BC.GasterBlaster(1, Vector2(0, 0), Vector2(300, 700), 0, 0, 2)
	BC.GasterBlaster(2, Vector2(0, 0), Vector2(300, 500), 0, 0, 2)
	pass
	
func Attack2() -> void:
	pass
	
func Attack3() -> void:
	pass

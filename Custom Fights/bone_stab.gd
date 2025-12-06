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

func CustomBoneStab() -> void:
	var BoneStab : Bone_Stab = BC.BoneStab(0, 75, 3, 1)
	
	var warn : Attack_Warning = BoneStab.attackWarning
	
	warn.set_size(Vector2(warn.Sprite.size.x * 3, 0))
	
	while warn.Sprite.size.y < 75 * 3:
		warn.set_size(Vector2(warn.Sprite.size.x * 3, warn.Sprite.size.y * 3 + 1))
		await get_tree().physics_frame
		if not warn:
			break

func CustomBoneStabSimple() -> void:
	var BoneStab : Bone_Stab = BC.BoneStab(0, 75, 3, 1)
	
	var warn : Attack_Warning = BoneStab.get_node("AttackWarning")
	
	warn.size.y = 0
	
	while warn.size.y < 65:
		warn.size.y += 1
		await get_tree().physics_frame
		if not warn:
			break
	

func AttackStart() -> void:
	match BC.AttackTurns:
		0:
			Attack1()
		1:
			Attack2()
		2:
			Attack3()

func Attack1() -> void:
	BC.CombatBox(Rect2(800, 720, 1200-800, 1152-720))
	BC.CombatBoxInstant()
	await Globals.Wait(1)
	var BoneStab1 : Bone_Stab = BC.BoneStab(0, 75, 3, 1)
	await Globals.Wait(4.5)
	CustomBoneStabSimple()
	#BoneStab1.set_masked(false)
	#var BoneStab2 : Bone_Stab = BC.BoneStab(1, 125, 1, 20)
	#var BoneStab3 : Bone_Stab = BC.BoneStab(2, 75, 1, 20)
	#var BoneStab4 : Bone_Stab = BC.BoneStab(3, 50, 1, 20)
	var Bones : Array[StandardBone] = BoneStab1.bonesArray
	#Bones.append_array(BoneStab2.bonesArray)
	#Bones.append_array(BoneStab3.bonesArray)
	#Bones.append_array(BoneStab4.bonesArray)
	#BoneStab1.set_masked(false)
	return
	var index : int = 0
	while true:
		if not BoneStab1: break
		if BoneStab1.is_queued_for_deletion(): break
		
		var boneI : int = 0
		for cBone in Bones:
			var closeness : int = abs(index - boneI)
			var yPosition = cBone.position.rotated(deg_to_rad(BoneStab1.point_rotation)).y
			
			if closeness <= 5:
				if yPosition > -300:
					cBone.position.y -= 25
			else:
				if yPosition < 0:
					cBone.position.y += 2
			boneI += 1
		index += 1
		if index > Bones.size():
			index = 0
		await Globals.Wait(0.01)
	#BC.ReturnToMenu()
	pass
	
func Attack2() -> void:
	pass
	
func Attack3() -> void:
	pass

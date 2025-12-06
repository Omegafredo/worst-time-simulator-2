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
				


const BoneASpinMeta := "BoneASpinning"

func SpinBone(bone : StandardBone) -> void:
	var rotation_acceleration := 0.0
	
	bone.set_meta(BoneASpinMeta, true)
	
	while bone.get_meta(BoneASpinMeta):
		
		if rotation_acceleration < 1.25:
			rotation_acceleration += 1 * get_process_delta_time()
		
		bone.rotation_degrees += rotation_acceleration
		
		await get_tree().process_frame

func ShootSpinningBone(bone : StandardBone, ShootSpeed : float, Direction : float) -> void:
	bone.set_meta(BoneASpinMeta, false)
	bone.Direction = Direction
	var t = bone.create_tween().set_parallel(true)
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_SINE)
	bone.rotation_degrees = fposmod(bone.rotation_degrees, 360)
	t.tween_property(bone, "rotation_degrees", Direction + 90 + 360, 0.4)
	t.set_ease(Tween.EASE_IN)
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(bone, "Speed", ShootSpeed, 0.75)


func AttackStart() -> void:
	match BC.AttackTurns:
		0:
			Attack1()
		1:
			Attack2()
		2:
			Attack3()

func Attack1() -> void:
	BC.CombatBoxLegacy(200, 820, 1700, 1100)
	BC.CombatBoxInstant()
	BC.SoulMode(1)
	var b1 : StandardBone
	
	for i in range(7):
		b1 = BC.Bone(Vector2(1675, 1175), 50, 180, 0)
		var t = b1.create_tween().set_parallel(true)
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_EXPO)
		t.tween_property(b1, "position:y", b1.position.y - 125, 1)
		#t.parallel().tween_interval(0.2)
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_CUBIC)
		t.tween_property(b1, "Speed", 700, 3)
		await Globals.Wait(0.15)
	await Globals.Wait(1.5)
	var t = b1.create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(b1, "Speed", 0, 3)
	await Globals.Wait(0.5)
	t = b1.create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(b1, "position:y", 400, 3)
	await Globals.Wait(0.5)
	while b1.position.y > 1050 - b1.Height:
		await get_tree().process_frame
	print("switched")
	b1.set_masked(false)
	SpinBone(b1)
	await Globals.Wait(1.75)
	t.kill()
	var dir = rad_to_deg(b1.position.angle_to_point(BC.Soul.position))
	ShootSpinningBone(b1, 2000, dir)
	
	await Globals.Wait(2)
	
	pass
	
func Attack2() -> void:
	pass
	
func Attack3() -> void:
	pass

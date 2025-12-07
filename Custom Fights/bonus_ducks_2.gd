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
			# On the first new line, you use [indent], afterwards it is not required.
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

func Fucking_Spinning_Platform_XD(Platform,Accel : bool, Max_Accel : float, ok : float) -> void:
		
		var speed = 0.01;
		
		while true:
			
			if Accel:
				speed += 0.0001;
				if speed >= Max_Accel:
					speed = Max_Accel
			Platform.rotation_degrees -= speed * ok
			await get_tree().process_frame
			if not Platform:
				break 




func Fucking_Coming_Back_Bones_XD(Bone_Amount_Per_Side : int, Repeat_Amount : float) -> void:
	var Amount = 0
	while true:
		if Bone_Amount_Per_Side < 0: Bone_Amount_Per_Side = 1
		if Amount >= Repeat_Amount:
			break
		
		var Bones = 1
		
		while Bones <= Bone_Amount_Per_Side:
			Bones += 1
			var rng = RandomNumberGenerator.new()
			var gamble = rng.randf_range(1,100)
			var nr = 0
			if gamble > 50:
				nr = 2
			else:
				nr = 1
			
			var Bone = BC.Bone(Vector2(350,920),16,0,350,nr)
			
			await Globals.Wait(0.3)
		Amount += 1
		await Globals.Wait(2)

func L_R_Bone_Barrage(Amount_Of_Bones : int = 60) -> void:
	
	var Bones_Shot = 0
	var L_R = 1
	
	while Bones_Shot <= Amount_Of_Bones:	
		var rng = RandomNumberGenerator.new()
		var gamble = rng.randf_range(700,1100)
		
		var Rotation = 0
		if L_R == 1:
			Rotation = 0
		else:
			Rotation = 180
		
		
		var Bone = BC.Bone(Vector2(950-(1150*L_R),gamble),50,Rotation,600,0,false)
		Bone.rotation_degrees = 90
		L_R *= -1
		Bones_Shot += 1
		await Globals.Wait(0.2)
	
	pass


func AttackStart() -> void:
	match BC.AttackTurns:
		0:
			Attack1()
		1:
			Attack2()
		2:
			Attack3()

func Attack1() -> void:
	
	
	BC.CombatBox(Rect2(450,720,1000,400))
	BC.CombatBoxInstant()
	
	#var Platform = BC.Platform(Vector2(600,900),500,0,100,true)
	#Platform.rotation_degrees -= 90
	
	#while Platform.position.x <= 950:
	#	await get_tree().process_frame
	#Platform.Speed = 0
	
	await Globals.Wait(0.5)
	
	#Fucking_Spinning_Platform_XD(Platform,true,0.05,-1)	
	
	BC.SoulMode(1)
	
	await Globals.Wait(0.5)
	
	var Bone_Stab_SteamHappy_Emoji = BC.BoneStab(0,62,1,12,0,36,1000)
	var Bone_Stab_SteamSad_Emoji = BC.BoneStab(2,62,1,12,0,36,1000)
	
	await Globals.Wait(1.02)
	
	
	BC.SoulMode(0)
	
	await Globals.Wait(0.5)
	
	Fucking_Coming_Back_Bones_XD(28,1)
	
	BC.CombatBoxSpeed(30)
	BC.CombatBox(Rect2(750, 720, 400, 400))
	
	await Globals.Wait(8)
	
	BC.GasterBlaster(2.66,Vector2(400,920),Vector2(1500,920),180,3.25,2.5)
	BC.GasterBlaster(2.66,Vector2(1500,920),Vector2(400,920),0,3.25,2.5)
	
	await Globals.Wait(4)
	
	BC.BoneStab(1,15,0.2,1,0,36,400)
	BC.BoneStab(3,15,0.2,1,0,36,400)
	await Globals.Wait(0.55)
	BC.BoneStab(1,30,0.2,1,0,36,400)
	BC.BoneStab(3,30,0.2,1,0,36,400)
	await Globals.Wait(0.55)
	BC.BoneStab(1,45,0.2,1,0,36,400)
	BC.BoneStab(3,45,0.2,1,0,36,400)
	await Globals.Wait(0.55)
	BC.BoneStab(1,52,0.2,16,0,36,400)
	BC.BoneStab(3,52,0.2,16,0,36,400)
	
	await Globals.Wait(0.2)
	BC.BoneStab(0,140,3,10,2)
	
	await Globals.Wait(2)
	
	L_R_Bone_Barrage(40)
	
	
	pass
	
func Attack2() -> void:
	pass
	
func Attack3() -> void:
	pass

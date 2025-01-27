extends Node
class_name BattleController

var BonePath := preload("res://Scenes/bone_v.tscn")
var BlasterPath := preload("res://Scenes/gaster_blaster.tscn")
var PlatformPath := preload("res://Scenes/platform.tscn")
var StrikeAnimation := preload("res://Scenes/strike.tscn")

@onready var CombatZone := $CombatZoneCorner/CombatZone
@export var Soul : CharacterBody2D
@export var SansHimself : Node2D
@export var SpeechBubble : TextSystem
@export var MenuText : TextSystem
@export var MenuButtons : Node
@export var MenuCursor : AudioStreamPlayer
@export var HealthText : Label
@export var HealthBar: Sprite2D
#@export var HpIcon: Sprite2D = $UI/HpIcon
@export var Target : FightTarget
@export var KrIcon: Sprite2D
@export var PlayerName: Label
@export var AttackList : Node

var CurrentEnemy = "Sans"

#region Attack Calls

func CombatBox(NewRect : Rect2):
	CombatZone.Moving = true
	CombatZone.BoxSize.position = NewRect.position
	CombatZone.BoxSize.end = NewRect.size
	
func CombatBoxInstant(NewRect : Rect2):
	CombatBox(NewRect)
	CombatZone.SetPos()

func CombatBoxSpeed(NewSpeed : float):
	CombatZone.Speed = NewSpeed
	
func CombatBoxRotate(NewRotation : float, RotationSpeed : float = 2):
	var tween = get_tree().create_tween()
	tween.tween_property(CombatZone, "rotation_degrees", NewRotation, RotationSpeed)
	

func Bone(StartPos : Vector2, NewHeight : float, NewDirection : float, NewSpeed : float, MaskedState : bool = true) -> Attack:
	var newBone = BonePath.instantiate()
	newBone.position = StartPos
	newBone.Height = NewHeight
	newBone.Direction = NewDirection
	newBone.Speed = NewSpeed
	add_child(newBone)
	newBone.Masked = MaskedState
	return newBone
	
func GasterBlaster(Size : int, StartPos : Vector2, EndPos : Vector2, Angle : float, DelayTime : float, ShootTime : float) -> Gaster_Blaster:
	var newBlaster : Gaster_Blaster = BlasterPath.instantiate()
	newBlaster.Size = Size
	newBlaster.position = StartPos
	newBlaster.rotation_degrees = 90
	add_child(newBlaster)
	newBlaster.BlasterMove(EndPos, Angle, DelayTime, ShootTime)
	newBlaster.Masked = false
	newBlaster.Enter()
	return newBlaster
	
#func SendBlasterAttack(Blaster : Node2D, blasterAttack : BlasterAttack) -> void:
	#Blaster.Path.push_front(blasterAttack)
	
func SoulMode(NewSoulType : int):
	Soul.Change_Soul(NewSoulType)

func SoulSlam(SlamDirection : int):
	Soul.Change_Soul(1)
	Soul.Slammed = true
	Soul.gravityDir = SlamDirection

func Platform(StartPos : Vector2, Width : float, Direction : float, Speed : float, MaskedState : bool = false) -> Attack:
	var newPlatform : Attack = PlatformPath.instantiate()
	newPlatform.position = StartPos
	newPlatform.Width = Width
	newPlatform.Direction = Direction
	newPlatform.Speed = Speed
	add_child(newPlatform)
	newPlatform.Masked = MaskedState
	return newPlatform

#endregion

var AttackTurns : int = 0
var AmountTurns : int = 0

func _ready():
	InitialiseBattle()
	if Globals.CustomMode:
		Globals.CustomAttackScript.reload()
		AttackList.set_script(Globals.CustomAttackScript)
	
	#SpeechBubble.setText("Waiting system [Wait=0.5]Test")
	
	#
	#await SpeechBubble.receivedInput
	#SpeechBubble.setText("There's also [wave amp=20.0 freq=5.0 connected=1][rainbow]BBCode![/rainbow][/wave]")
	#await SpeechBubble.receivedInput
	#await Globals.Wait(1.5)
	#SpeechBubble.changeMode(1)
	#SpeechBubble.setText("Serious text as well")
	#
	#await SpeechBubble.receivedInput
	#await Globals.Wait(1)
	#SoulMode(1)
	#await Globals.Wait(1)
	#SoulSlam(2)
	#await Globals.Wait(0.5)
	#SoulSlam(0)
	#await Globals.Wait(0.5)
	#SoulSlam(2)
	#await Globals.Wait(1)
	SoulMode(1)
	#await Globals.Wait(2)
	Bone(Vector2(1200, 1000),50,180,70,true)
	Platform(Vector2(1200, 1000),50,180,70,true)
	CombatBox(Rect2(400, 720, 1400, 1152))
	#
	#await Globals.Wait(2)
	#Bone(Vector2(1100, 750), 30, 180, 150)
	#Bone(Vector2(1100, 950), 30, 180, 150, false)
	##
	#await Globals.Wait(1)
	##
	#CombatBoxRotate(780)
	#
	#await Globals.Wait(2.5)
	#
	#GasterBlaster(0, Vector2(0,0), Vector2(435, 684), 0, 1, 2)
	#GasterBlaster(2, Vector2(0,0), Vector2(435, 400), 0, 1, 2)
	#var test1 = GasterBlaster(1, Vector2(0,0), Vector2(435, 884), 0, 1, 2)
	#test1.BlasterMoveManual(Vector2(400,600), 120)
	#test1.BlasterMoveManual(Vector2(600, 600), 75, 2)
	await Globals.Wait(7)
	#test1.ForceFire(2)
	ReturnToMenu()
	
	
func InitialiseBattle():
	request_ready()
	CombatBoxInstant(Rect2(111, 720, 1839, 1152))
	
func InitializeAttack():
	MenuMode = false
	MenuControl = NONE
	Soul.show()
	CombatBox(Rect2(800, 720, 1200, 1152))
	Soul.position = Vector2(1000, 1000)
	await Globals.Wait(2)
	ReturnToMenu()

func ReturnToMenu():
	CombatBoxRotate(round(CombatZone.rotation_degrees / 180.0) * 180.0, 0.5)
	CombatBox(Rect2(111, 720, 1839, 1152))
	SelectedMenu = "Main"
	MoveMenu(0)
	MenuMode = true
	await CombatZone.DoneMoving
	MenuControl = ACTIONABLE
	MenuText.setText("* You feel like you're going to\n[indent]have the worst time of your\nlife.")
	

func _process(_delta) -> void:
	if MenuMode and MenuControl == ACTIONABLE:
		if Input.is_action_just_pressed("left"):
			MoveMenu(-1)
		elif Input.is_action_just_pressed("right"):
			MoveMenu(1)
		if Input.is_action_just_pressed("up"):
			MoveMenu(0, -1)
		elif Input.is_action_just_pressed("down"):
			MoveMenu(0, 1)
		if Input.is_action_just_pressed("accept"):
			ConfirmSelect()
		elif Input.is_action_just_pressed("cancel"):
			ReturnMenu()
	
	PlayerName.text = str(Globals.PlayerName + "     LV  19")
	HealthText.position.x = HealthBar.position.x + HealthBar.scale.x + 150
	HealthText.text = str(str(Globals.HP) + "  /  " + str(Globals.MaxHP))
	KrIcon.position.x = HealthBar.position.x + HealthBar.scale.x + 68
	
	if Globals.KR > 0:
		HealthText.modulate = Color("#ff00ff")
	else:
		HealthText.modulate = Color(1, 1, 1)
	
	# Godot has a bug with it not updating the scale, current workaround:
	$"Attack Origin Point".update_scale = false
	$"Attack Origin Point".update_scale = true
	


@export var SelectableOptions: Node2D
var SelectedMenu = "Main"
var OptionsArray : Array:
	get():
		return SelectableOptions.get_children()
var CurrentOption : BattleMenuSelection:
	get():
		for option in OptionsArray:
			if option.ID == SelectIndex:
				return option
		return null
var MenuHistory := Array(["Main"], TYPE_STRING, "", null)
const OptionSoulOffset : Vector2 = Vector2(-50, 55)

enum {ACTIONABLE, CONFIRMABLE, NONE}

var MenuControl := NONE
var MenuMode := false
var SelectIndex : int = 0

var IndexPosition : Vector2i:
	get():
		var x : int
		var y : int
		
		if SelectIndex % 4 in [2, 3]:
			y = 1
		else:
			y = 0
		
		#x = int(SelectIndex / 2) % 2 + 2 * int(SelectIndex / 4)
		#x = SelectIndex - y * 2
		
		
		for i in range(SelectIndex):
			if SelectIndex % 4 in [0, 1]:
				if i % 4 in [0, 1]:
					x += 1
			elif SelectIndex % 4 in [2, 3]:
				if i % 4 in [2, 3]:
					x += 1
		
		if SelectIndex % 4 in [0, 2]:
			x - 1
		
		return Vector2i(x, y)
	set(value):
		var n : int
		
		if value.x % 2 == 0:
			n = value.x * 2
		else:
			n = (value.x - 1) * 2 + 1
		SelectIndex = n + value.y * 2
		

const MenuSoulOffset := Vector2(49, 64)


func MoveMenu(HDirection : int, VDirection : int = 0) -> void:
	var TempIndex = SelectIndex
	for menu in MenuButtons.get_children():
		menu.play("default")
	if SelectedMenu == "Main":
		SelectIndex += HDirection
		if SelectIndex > 3:
			SelectIndex = 0
		elif SelectIndex < 0:
			SelectIndex = 3
		Soul.position = MenuButtons.get_child(SelectIndex).position + MenuSoulOffset
		MenuButtons.get_child(SelectIndex).play("active")
	else:
		if SelectableOptions.get_child_count() > 1:
			#if SelectIndex == 0 and HDirection == -1:
				#SelectIndex = SelectableOptions.get_child_count() - 3
			#elif SelectIndex == 2 and HDirection == -1:
				#SelectIndex = SelectableOptions.get_child_count() - 1
			#elif SelectIndex == SelectableOptions.get_child_count() - 3 and HDirection == 1:
				#SelectIndex = 0
			#elif SelectIndex == SelectableOptions.get_child_count() -1 and HDirection == 1:
				#SelectIndex = 2
			#elif SelectIndex % 4 in [0, 1] and VDirection == 1:
				#SelectIndex += 2
				#MenuCursor.play()
			#elif SelectIndex % 4 in [2, 3] and VDirection == -1:
				#SelectIndex -= 2
				#MenuCursor.play()
			#elif SelectIndex % 4 in [1, 3] and HDirection == 1:
				#SelectIndex += 3
			#elif SelectIndex % 4 in [0, 2] and HDirection == -1:
				#SelectIndex -= 3
			#else:
				#SelectIndex += HDirection
			if IndexPosition.x == 0 and HDirection == -1:
				IndexPosition.x = SelectableOptions.get_child_count()
				while SelectIndex > SelectableOptions.get_child_count() - 1:
					IndexPosition.x -= 1
			else:
				if VDirection + IndexPosition.y in [0, 1] and VDirection != 0:
					if (VDirection == 1 and SelectIndex + 2 < SelectableOptions.get_child_count()) \
					or VDirection == -1:
						IndexPosition.y += VDirection
				else:
					IndexPosition.x += HDirection
				
				if SelectIndex > SelectableOptions.get_child_count() - 1:
					IndexPosition.x = 0
		Soul.position = CurrentOption.global_position + OptionSoulOffset
		for option in OptionsArray:
			if option.get_index()/4 == SelectIndex/4:
				option.show()
			else:
				option.hide()
	if TempIndex != SelectIndex:
		MenuCursor.play()
	
func ConfirmSelect() -> void:
	if SelectedMenu == "Main":
		ChangeMenu(MenuButtons.get_child(SelectIndex).name)
	else:
		CurrentOption.activated.emit()
		
	MenuCursor.play()
	
func ChangeMenu(MenuType: String) -> void:
	if SelectedMenu == "Main":
		MenuText.hideText()
	SelectedMenu = MenuType
	MenuHistory.append(MenuType)
	SetMenuOptions()
	SelectIndex = 0
	MoveMenu(0)

func ReturnMenu() -> void:
	if SelectedMenu != "Main":
		SelectedMenu = MenuHistory[-2]
		if SelectedMenu == "Main":
			for menu in MenuButtons.get_children():
				if menu.name == MenuHistory[-1]:
					SelectIndex = menu.get_index()
		MenuHistory.pop_back()
		SetMenuOptions()
		if SelectedMenu != "Main":
			SelectIndex = 0
		MoveMenu(0)

func SetMenuOptions() -> void:
	for option in OptionsArray:
		option.queue_free()
	match SelectedMenu:
		"Fight", "Act":
			var Selection = CreateMenuInput(CurrentEnemy, 0)
			if SelectedMenu == "Fight":
				Selection.activated.connect(FightAction)
			elif SelectedMenu == "Act":
				Selection.activated.connect(ChangeMenu.bind("ActMenu"))
		"ActMenu":
			ActMenu()
		"Item":
			ItemMenu()
		"Mercy":
			CreateMenuInput("Spare", 0)
		"Main":
			MenuText.unhideText()
		
			
func ClearMenuOptions() -> void:
	for option in OptionsArray:
		option.queue_free()
	Soul.hide()
	
func ActMenu() -> void:
	var Check = CreateMenuInput("Check", 0)
	Check.activated.connect(CheckAction)
	
func ItemMenu() -> void:
	var i : int = 0
	for item : FoodItem in Globals.CurrentItems:
		CreateItemInput(item, i)
		i += 1
		
func FightAction() -> void:
	ClearMenuOptions()
	MenuControl = NONE
	Target.get_child(0).scale.x = 0.75
	Target.modulate.a = 0
	var tween = Target.create_tween()
	tween.tween_property(Target.get_child(0), "scale:x", 1, 0.5)
	tween.parallel().tween_property(Target, "modulate:a", 1, 0.5)
	Target.Start()
	
func _on_target_fight_end():
	var tween = Target.create_tween()
	tween.tween_property(Target.get_child(0), "scale:x", 0.75, 0.5)
	tween.parallel().tween_property(Target, "modulate:a", 0, 0.5)
	await Globals.Wait(0.6)
	InitializeAttack()
	
func _on_target_confirmed() -> void:
	StrikeEnemy()
	EnemyDodge(560, 0.4)
	await Globals.Wait(1)
	EnemyReturn()
	
func EnemyDodge(Position : float, Speed : float) -> void:
	var tween = SansHimself.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(SansHimself, "position:x", Position, Speed)
	
func EnemyReturn() -> void:
	var tween = SansHimself.create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(SansHimself, "position:x", 960, 0.6)
	
func StrikeEnemy() -> void:
	var Strike = StrikeAnimation.instantiate()
	Strike.position = SansHimself.position - Vector2(0, 220)
	Strike.play("default")
	add_child(Strike)
	
func CheckAction() -> void:
	if CurrentEnemy == "Sans":
		InitiateDescription(["* SANS 1 ATK 1 DEF\n* The easiest enemy...\n* But something feels different.", "[color=red]* But we've killed him before,\n[indent]we can do it again."])

func InitiateDescription(Dialogue : Array[String], EndAction : Callable = InitializeAttack) -> void:
	MenuControl = CONFIRMABLE
	MenuText.IsConfirmable = true
	MenuText.show()
	ClearMenuOptions()
	
	MenuText.appendText(Dialogue)
	await MenuText.endofdialogue
	EndAction.call()

func ItemHeal(HealAmount : int):
	Globals.HP += HealAmount

func ItemActivated(Item : BattleMenuItem):
	var HealthDesc : String
	if Item.Food.Health + Globals.HP >= Globals.MaxHP:
		HealthDesc = "* Your HP was maxed out."
	else:
		HealthDesc = "* You recovered " + str(Item.Food.Health) + " HP!"
	
	ItemHeal(Item.Food.Health)
	
	var FullDescription : Array[String] = ["* You eat the " + Item.Food.FullName + ".\n" + HealthDesc]
	FullDescription.append_array(Item.Food.AdditionalDescription)
	InitiateDescription(FullDescription)
	
	



const TextFont = preload("res://Resources/Fonts/styles/boxText.tres")

func CreateMenuInput(SetText: String, ID: int) -> BattleMenuSelection:
	var MenuSelection : BattleMenuSelection = BattleMenuSelection.new()
	MenuSelection.text = SetText
	var Selection : BattleMenuSelection = CreateTextInput(MenuSelection, ID)
	return Selection

func CreateItemInput(Item : FoodItem, ID: int) -> void:
	var ItemSelect : BattleMenuItem = BattleMenuItem.new()
	ItemSelect.text = Item.Name
	ItemSelect.Food = Item
	var NewItem = CreateTextInput(ItemSelect, ID)
	NewItem.activated.connect(ItemActivated.bind(ItemSelect))
	
func CreateTextInput(TextLabel : BattleMenuSelection, ID : int) -> BattleMenuSelection:
	TextLabel.position = Vector2(192 + (ID%2)*768, 0)
	if ID%4 in [2, 3] :
		TextLabel.position.y = 96
	TextLabel.size = Vector2(900, 100)
	TextLabel.scroll_active = false
	TextLabel.add_theme_font_override("normal_font", TextFont)
	TextLabel.add_theme_font_size_override("normal_font_size", 96)
	TextLabel.ID = ID
	SelectableOptions.add_child(TextLabel)
	return TextLabel

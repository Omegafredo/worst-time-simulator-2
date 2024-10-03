extends Node

var BonePath := load("res://Scenes/bone_v.tscn")
@onready var CombatZone := $CombatZoneCorner/CombatZone
@onready var Soul := %Player
@onready var SpeechBubble := $SpeechBubble
@onready var MenuText := $UI/BoxText
@onready var MenuButtons := $UI/MenuButtons
@onready var MenuCursor := $Audio/MenuCursor
@onready var HealthText := $UI/Health
@onready var HealthBar: Sprite2D = $UI/HealthBar
#@onready var HpIcon: Sprite2D = $UI/HpIcon
@onready var KrIcon: Sprite2D = $UI/KrIcon
@onready var PlayerName: Label = $UI/Name

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
	

func Bone(StartPos : Vector2, NewHeight : float, NewDirection : float, NewSpeed : float, MaskedState : bool = true) -> Object:
	var newBone = BonePath.instantiate().get_child(0)
	newBone.position = StartPos
	newBone.Height = NewHeight
	newBone.Direction = NewDirection
	newBone.Speed = NewSpeed
	add_child(newBone.get_parent())
	newBone.get_parent().Masked = MaskedState
	return newBone
	
func SoulMode(NewSoulType : int):
	Soul.Change_Soul(NewSoulType)

func SoulSlam(SlamDirection : int):
	Soul.Change_Soul(1)
	Soul.Slammed = true
	Soul.gravityDir = SlamDirection
	
func _ready():
	InitialiseBattle()
	
	
	#SpeechBubble.AskForInput = true
	#SpeechBubble.setText("Waiting system")
	#
	#SpeechBubble.continueText(" You can continue text", 1)
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
	#SoulMode(0)
	#CombatBox(Rect2(400, 720, 900, 1152))
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
	ReturnToMenu()
	
func InitialiseBattle():
	request_ready()
	CombatBoxInstant(Rect2(111, 720, 1839, 1152))
	
func InitializeAttack():
	pass
	
func _process(_delta) -> void:
	if MenuMode and AllowControls:
		if Input.is_action_just_pressed("left"):
			MoveMenu(-1)
		elif Input.is_action_just_pressed("right"):
			MoveMenu(1)
		if Input.is_action_just_pressed("accept"):
			SelectMenu()
		elif Input.is_action_just_pressed("cancel"):
			ReturnMenu()
	
	PlayerName.text = str(Globals.PlayerName + "  LV19")
	HealthText.position.x = HealthBar.position.x + HealthBar.scale.x + 100
	HealthText.text = str(str(Globals.HP) + "/" + str(Globals.MaxHP))
	KrIcon.position.x = HealthBar.position.x + HealthBar.scale.x + 50
	
func ReturnToMenu():
	CombatBoxRotate(round(CombatZone.rotation_degrees / 180.0) * 180.0, 0.5)
	CombatBox(Rect2(111, 720, 1839, 1152))
	MoveMenu(0)
	MenuMode = true
	await CombatZone.DoneMoving
	AllowControls = true
	MenuText.setText("* You feel like you're going to\n[indent]have the worst time of your\nlife.")

@onready var SelectableOptions: Node2D = $UI/BoxText/SelectableOptions
var SelectedMenu = "Main"
var OptionsArray : Array:
	get():
		return SelectableOptions.get_children()
var CurrentOption : RichTextLabel:
	get():
		for option in OptionsArray:
			if option.get_meta("ID") == SelectIndex:
				return option
		return null
var MenuHistory := Array(["Main"], TYPE_STRING, "", null)
const OptionSoulOffset : Vector2 = Vector2(-50, 55)

var AllowControls := false
var MenuMode := false
var SelectIndex : int = 0

const MenuSoulOffset := Vector2(49, 64)


func MoveMenu(Direction : int) -> void:
	SelectIndex += Direction
	MenuCursor.play()
	for menu in MenuButtons.get_children():
		menu.play("default")
	if SelectedMenu == "Main":
		if SelectIndex > 3:
			SelectIndex = 0
		elif SelectIndex < 0:
			SelectIndex = 3
		Soul.position = MenuButtons.get_child(SelectIndex).position + MenuSoulOffset
		MenuButtons.get_child(SelectIndex).play("active")
	else:
		if SelectIndex > SelectableOptions.get_child_count() - 1:
			SelectIndex = 0
		elif SelectIndex < 0:
			SelectIndex = SelectableOptions.get_child_count() - 1
		Soul.position = CurrentOption.global_position + OptionSoulOffset
	
func SelectMenu() -> void:
	if SelectedMenu == "Main":
		ChangeMenu(MenuButtons.get_child(SelectIndex).name)
	
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
	if SelectedMenu in ["Fight", "Act"]:
		EnemySelect()
	if SelectedMenu == "Main":
		MenuText.unhideText()
		MenuText.DontSkipDuringThisParticularFrame()
	
func EnemySelect() -> void:
	CreateTextInput("Sans", 0)
	
const TextFont = preload("res://Resources/Fonts/styles/boxText.tres")

func CreateTextInput(SetText: String, ID: int) -> void:
	var RichText : RichTextLabel = RichTextLabel.new()
	RichText.text = SetText
	RichText.position = Vector2(150, 0)
	RichText.size = Vector2(900, 100)
	RichText.scroll_active = false
	RichText.add_theme_font_override("normal_font", TextFont)
	RichText.add_theme_font_size_override("normal_font_size", 96)
	RichText.set_meta("ID", ID)
	SelectableOptions.add_child(RichText)

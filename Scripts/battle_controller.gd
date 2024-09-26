extends Node

var BonePath := load("res://Scenes/bone_v.tscn")
@onready var CombatZone := $CombatZone
@onready var Soul := %Player
@onready var SpeechBubble := $SpeechBubble
@onready var MenuText := $BoxText
@onready var MenuButtons := $MenuButtons
@onready var MenuCursor := $MenuCursor

var AllowControls := false
var MenuMode := false
var SelectIndex : int = 0

const SoulOffset := Vector2(49, 64)

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
	

func Bone(StartPos : Vector2, NewHeight : float, NewDirection : float, NewSpeed : float) -> Object:
	var newBone = BonePath.instantiate().get_child(0)
	newBone.position = StartPos
	newBone.Height = NewHeight
	newBone.Direction = NewDirection
	newBone.Speed = NewSpeed
	add_child(newBone)
	newBone.get_parent().Masked = true
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
	CombatBox(Rect2(111, 720, 700, 1152))
	
	await Globals.Wait(2)
	Bone(Vector2(700, 800), 50, 180, 100)
	##
	#await Globals.Wait(1)
	##
	#CombatBoxRotate(780)
	#
	#await Globals.Wait(2.5)
	#
	#ReturnToMenu()
	
func _process(_delta) -> void:
	if MenuMode and AllowControls:
		if Input.is_action_just_pressed("left"):
			MoveMenu(-1)
		elif Input.is_action_just_pressed("right"):
			MoveMenu(1)
	
func InitialiseBattle():
	request_ready()
	CombatBoxInstant(Rect2(111, 720, 1839, 1152))
	$Name.text = str(Globals.PlayerName + "  LV19")
	
func ReturnToMenu():
	CombatBoxRotate(round(CombatZone.rotation_degrees / 180.0) * 180.0, 0.5)
	CombatBox(Rect2(111, 720, 1839, 1152))
	MoveMenu(0)
	MenuMode = true
	await CombatZone.DoneMoving
	AllowControls = true
	MenuText.setText("* You feel like you're going to\n[indent]have the worst time of your\nlife.")

func MoveMenu(Direction : int) -> void:
	SelectIndex += Direction
	MenuCursor.play()
	if SelectIndex > 3:
		SelectIndex = 0
	elif SelectIndex < 0:
		SelectIndex = 3
	Soul.position = MenuButtons.get_child(SelectIndex).position + SoulOffset
	for menu in MenuButtons.get_children():
		menu.play("default")
	MenuButtons.get_child(SelectIndex).play("active")
	

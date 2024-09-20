extends Node

var BonePath := load("res://Scenes/bone_v.tscn")
@onready var CombatZone := $CombatZone
@onready var Soul := %Player
@onready var SpeechBubble := $SpeechBubble

func CombatBox(TopLeftX : float, TopLeftY : float, BottomRightX : float, BottomRightY : float):
	CombatZone.TopLeft = Vector2(TopLeftX, TopLeftY)
	CombatZone.BottomRight = Vector2(BottomRightX, BottomRightY)
	
func CombatBoxInstant(TopLeftX : float, TopLeftY : float, BottomRightX : float, BottomRightY : float):
	CombatBox(TopLeftX, TopLeftY, BottomRightX, BottomRightY)
	CombatZone.SetPos()

func CombatBoxSpeed(NewSpeed : float):
	CombatZone.Speed = NewSpeed
	
func CombatBoxRotate(NewRotation : float):
	var tween = get_tree().create_tween()
	tween.tween_property(CombatZone, "rotation_degrees", NewRotation, 2)
	

func Bone(NewX : float, NewY : float, NewHeight : float, NewDirection : float, NewSpeed : float) -> Object:
	var newBone = BonePath.instantiate()
	newBone.position.x = NewX
	newBone.position.y = NewY
	newBone.Height = NewHeight
	newBone.Direction = NewDirection
	newBone.Speed = NewSpeed
	add_child(newBone)
	return newBone
	
func SoulMode(NewSoulType : int):
	Soul.Change_Soul(NewSoulType)

func SoulSlam(SlamDirection : int):
	Soul.Change_Soul(1)
	Soul.Slammed = true
	Soul.gravityDir = SlamDirection
	
func _ready():
	request_ready()
	CombatBoxInstant(100, 900, 1800, 1300)
	SpeechBubble.AskForInput = false
	SpeechBubble.setText("Waiting system")
	
	await SpeechBubble.textDone
	await Globals.Wait(1)
	
	SpeechBubble.continueText(" You can continue text")
	
	await SpeechBubble.textDone
	SpeechBubble.AskForInput = true
	await Globals.Wait(1.5)
	SpeechBubble.setText("There's also [wave amp=20.0 freq=5.0 connected=1][rainbow]BBCode![/rainbow][/wave]")
	await SpeechBubble.textDone
	await Globals.Wait(1.5)
	SpeechBubble.changeMode(1)
	SpeechBubble.setText("Should be burning in hell.")
	
	
	#await Globals.Wait(3)
	#SoulMode(1)
	#await Globals.Wait(5)
	#SoulSlam(2)
	#await Globals.Wait(2)
	#SoulSlam(1)
	#await Globals.Wait(2)
	#SoulSlam(0)
	#await Globals.Wait(1)
	#SoulMode(0)
	#CombatBox(100, 900, 500, 1300)

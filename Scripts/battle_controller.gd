extends Node

var BonePath := load("res://Scenes/bone_v.tscn")
@onready var CombatZone := $CombatZone
@onready var Soul := %Player

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
	

func Bone(NewX : float, NewY : float, NewHeight : float, NewDirection : float, NewSpeed : float):
	var newBone = BonePath.instantiate()
	newBone.position.x = NewX
	newBone.position.y = NewY
	newBone.Height = NewHeight
	newBone.Direction = NewDirection
	newBone.Speed = NewSpeed
	add_child(newBone)
	
func SoulMode(NewSoulType : int):
	Soul.Change_Soul(NewSoulType)

func SoulSlam(SlamDirection : int):
	Soul.Change_Soul(1)
	Soul.Slammed = true
	Soul.gravityDir = SlamDirection
	
func _ready():
	request_ready()
	CombatBoxInstant(100, 900, 1800, 1300)
	$SpeechBubble.AskForInput = false
	$SpeechBubble.setText("Wait system")
	
	print("test1")
	await $SpeechBubble.textDone
	print("test3")
	await Global_Func.Wait(3)
	
	$SpeechBubble.continueText(" Continuing text")
	
	
	#await Global_Func.Wait(3)
	#SoulMode(1)
	#await Global_Func.Wait(5)
	#SoulSlam(2)
	#await Global_Func.Wait(2)
	#SoulSlam(1)
	#await Global_Func.Wait(2)
	#SoulSlam(0)
	#await Global_Func.Wait(1)
	#SoulMode(0)
	#CombatBox(100, 900, 500, 1300)

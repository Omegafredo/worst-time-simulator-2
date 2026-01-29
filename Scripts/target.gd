extends Node2D
class_name FightTarget

@export var Sprite : AnimatedSprite2D

const Speed : float = 450
const SideRight : float = 320
const SideLeft : float = -345

var Confirmable := false
var Confirmed := false
var Active := false
var RightDir : bool

signal end
signal confirmed

func Start() -> void:
	Confirmable = false
	show()
	Sprite.stop()
	Sprite.frame = 0
	ChooseDirection()
	Active = true
	await Globals.Wait(0.05)
	Confirmable = true
	

func Activate() -> void:
	Confirmed = true
	Sprite.play("default")
	confirmed.emit()
	await Globals.Wait(0.5)
	End()

func End() -> void:
	Confirmable = false
	Confirmed = false
	Active = false
	end.emit()


func ChooseDirection() -> void:
	RightDir = randi() % 2 == 0
	if RightDir:
		Sprite.position.x = SideLeft
	else:
		Sprite.position.x = SideRight
	


func _process(delta):
	if !Confirmed and Active:
		var tempspeed = Speed
		
		if !RightDir:
			tempspeed *= -1
		
		Sprite.position.x += tempspeed * delta
		
		if RightDir:
			if Sprite.position.x > SideRight - 50:
				End()
		else:
			if Sprite.position.x < SideLeft + 50:
				End()
		
		if Input.is_action_just_pressed("accept"):
			if Confirmable:
				Activate()

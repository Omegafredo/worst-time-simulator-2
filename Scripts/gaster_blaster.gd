extends Node2D

enum {STATE_ENTER, STATE_WAIT, STATE_FIRE, STATE_LEAVE, STATE_DONE}

var CurrentState = STATE_ENTER

var DelayTime : float
var ShootTime : float
var MoveTo : Vector2
var AngleTo : float

var Delays : Array[float]
var Shoots : Array[float]
var Moves : Array[Vector2]
var Angles : Array[float]

const ENTER_TIME : float = 0.5
var EXIT_SPEED : float = 200

var Size : int:
	set(d):
		match d:
			0:
				scale = Vector2(5, 3)
			1:
				scale = Vector2(5, 5)
			2:
				scale = Vector2(8, 8)

@onready var BlasterSprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var Blast = $Blast
@onready var Hitbox = $Area2D

var on_screen : bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	Blast.scale.y = 0
	await Globals.Wait(1)
	Fire()
	CurrentState = STATE_WAIT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if CurrentState == STATE_WAIT:
		if DelayTime <= 0:
			Fire()
		DelayTime -= delta
	
	if CurrentState == STATE_FIRE:
		if Moves.size() <= 1:
			Exit()
			
		
	if CurrentState in [STATE_FIRE, STATE_LEAVE]:
		if ShootTime <= 0:
			Stop()
		ShootTime -= delta
		
	if CurrentState in [STATE_LEAVE, STATE_DONE]:
		if on_screen:
			global_position -= Vector2(EXIT_SPEED * delta, 0).rotated(rotation)
			
			if EXIT_SPEED <= 1800:
				EXIT_SPEED += 2000 * delta
	
	
	#match CurrentState:
		#STATE_WAIT:
			#if DelayTime <= 0:
				#Fire()
			#DelayTime -= delta
		#STATE_FIRE:
			#if Moves.size() <= 1:
				#Exit()
				#print("test2")
		#STATE_FIRE, STATE_LEAVE:
			#if ShootTime <= 0:
				#Stop()
			#ShootTime -= delta
		#STATE_LEAVE, STATE_DONE:
			#if on_screen:
				#global_position -= Vector2(EXIT_SPEED * delta, 0).rotated(rotation)
				#print("test")

func Enter() -> void:
	SetMoves()
	CurrentState = STATE_ENTER
	BlasterSprite.play("default")
	await Move(ENTER_TIME)
	CurrentState = STATE_WAIT

func Exit() -> void:
	CurrentState = STATE_LEAVE

func Fire() -> void:
	BlasterSprite.play("fire")

var SineTween : Tween

func Shoot() -> void:
	Hitbox.monitoring = true
	CurrentState = STATE_FIRE
	Blast.show()
	var tween = Blast.create_tween()
	tween.tween_property(Blast, "scale:y", 1, 0.5)
	await tween.finished
	SineTween = Blast.create_tween()
	SineTween.set_ease(Tween.EASE_IN_OUT)
	SineTween.set_trans(Tween.TRANS_SINE)
	SineTween.set_loops()
	SineTween.tween_property(Blast, "scale:y", 1.2, 0.08)
	SineTween.tween_property(Blast, "scale:y", 1.0, 0.08)
	
func Stop() -> void:
	PopMoves()
	SineTween.kill()
	var tween = Blast.create_tween()
	tween.tween_property(Blast, "scale:y", 0, 0.2)
	Hitbox.monitoring = false
	if !Moves.size() <= 0:
		Enter()
	else:
		CurrentState = STATE_DONE
	await tween.finished
	Blast.hide()

func Move(MoveTime : float) -> void:
	var tween = self.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", MoveTo, MoveTime)
	tween.parallel().tween_property(self, "rotation_degrees", AngleTo, MoveTime)
	await tween.finished
	
func ForceMove(MoveTime : float) -> void:
	MoveTo = Moves[0]
	AngleTo = Angles[0]
	Move(MoveTime)
	PopMoves()
	
func SetMoves() -> void:
	MoveTo = Moves[0]
	AngleTo = Angles[0]
	DelayTime = Delays[0]
	ShootTime = Shoots[0]

func PopMoves() -> void:
	Moves.pop_front()
	Angles.pop_front()
	Delays.pop_front()
	Shoots.pop_front()

func _on_animated_sprite_2d_animation_looped():
	if BlasterSprite.animation == "fire":
		BlasterSprite.frame = 3

func _on_animated_sprite_2d_frame_changed():
	if BlasterSprite.animation == "fire":
		if BlasterSprite.frame == 3 and CurrentState == STATE_WAIT:
			Shoot()
		
func _on_visible_on_screen_notifier_2d_screen_exited():
	on_screen = false
	
func _on_visible_on_screen_notifier_2d_screen_entered():
	on_screen = true

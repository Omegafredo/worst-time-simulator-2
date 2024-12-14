extends Node2D

enum {STATE_ENTER, STATE_WAIT, STATE_FIRE, STATE_LEAVE, STATE_DONE}

var CurrentState = STATE_ENTER

var DelayTime : float
var ShootTime : float
var MoveTo : Vector2
var AngleTo : float
var WillShoot : bool

var Path : Array[BlasterAttack]

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

var forcedShoot : bool = false
var forcedShootTime : float


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
			if WillShoot:
				Fire()
			else:
				PopMoves()
				Enter()
		
		DelayTime -= delta
	
	if CurrentState == STATE_FIRE:
		if Path.size() <= 1:
			Exit()
			
		
	if CurrentState in [STATE_FIRE, STATE_LEAVE]:
		if ShootTime <= 0:
			PopMoves()
			Stop()
			if !Path.size() <= 0:
				Enter()
			else:
				CurrentState = STATE_DONE
		ShootTime -= delta
		
	if CurrentState in [STATE_LEAVE, STATE_DONE]:
		if on_screen:
			global_position -= Vector2(EXIT_SPEED * delta, 0).rotated(rotation)
			
			if EXIT_SPEED <= 1800:
				EXIT_SPEED += 2000 * delta
	
	if forcedShoot and forcedShootTime > 0:
		forcedShootTime -= delta
	elif forcedShoot:
		forcedShoot = false
		Stop()
	
	
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

func ForceFire() -> void:
	forcedShoot = true
	forcedShootTime = ShootTime
	Fire()

func Fire() -> void:
	BlasterSprite.play("fire")

var SineTween : Tween

func Shoot() -> void:
	Hitbox.monitoring = true
	Blast.show()
	var tween = Blast.create_tween()
	tween.tween_property(Blast, "scale:y", 1, 0.2)
	await tween.finished
	SineTween = Blast.create_tween()
	SineTween.set_ease(Tween.EASE_IN_OUT)
	SineTween.set_trans(Tween.TRANS_SINE)
	SineTween.set_loops()
	SineTween.tween_property(Blast, "scale:y", 1.2, 0.08)
	SineTween.tween_property(Blast, "scale:y", 1.0, 0.08)
	
func Stop() -> void:
	SineTween.kill()
	var tween = Blast.create_tween()
	tween.tween_property(Blast, "scale:y", 0, 0.2)
	Hitbox.monitoring = false
	await tween.finished
	Blast.hide()

func Move(MoveTime : float) -> void:
	var tween = self.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", MoveTo, MoveTime)
	tween.parallel().tween_property(self, "rotation_degrees", AngleTo, MoveTime)
	await tween.finished
	
func SetMoves() -> void:
	Path[0].AngleTo = AngleTo
	Path[0].MoveTo = MoveTo
	Path[0].DelayTime = DelayTime
	Path[0].ShootTime = ShootTime
	Path[0].Shoot = WillShoot

func PopMoves() -> void:
	Path.pop_front()
	
func BlasterMove(EndPos : Vector2, Angle : float, Delay : float, ShootT: float) -> void:
	var blasterAttack = BlasterAttack.new()
	blasterAttack.MoveTo = EndPos
	blasterAttack.AngleTo = Angle
	blasterAttack.DelayTime = Delay
	blasterAttack.ShootTime = ShootT
	blasterAttack.Shoot = true
	Path.push_front(blasterAttack)
	
	
func BlasterMoveFireless(EndPos : Vector2, Angle : float) -> void:
	var blasterAttack = BlasterAttack.new()
	blasterAttack.MoveTo = EndPos
	blasterAttack.AngleTo = Angle
	blasterAttack.Shoot = false
	Path.push_front(blasterAttack)

func _on_animated_sprite_2d_animation_looped():
	if BlasterSprite.animation == "fire":
		BlasterSprite.frame = 3

func _on_animated_sprite_2d_frame_changed():
	if BlasterSprite.animation == "fire":
		if BlasterSprite.frame == 3 and CurrentState == STATE_WAIT:
			if !forcedShoot:
				CurrentState = STATE_FIRE
			Shoot()
		
func _on_visible_on_screen_notifier_2d_screen_exited():
	on_screen = false
	
func _on_visible_on_screen_notifier_2d_screen_entered():
	on_screen = true

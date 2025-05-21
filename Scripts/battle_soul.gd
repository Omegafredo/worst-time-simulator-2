extends CharacterBody2D
class_name Player

enum {SOUL_RED, SOUL_BLUE, DEAD}

var Soul_Type := SOUL_RED

var gravityDir := 0:
	set(d):
		gravityDir = d
		up_direction = Vector2(0, -1).rotated(deg_to_rad(d * -90))

var gravity : float = 980

@export var SplitSprite : Texture2D

@export var SoulSprite : Sprite2D
@export var FadeSprite : Sprite2D
@export var Hitbox : Area2D
@onready var CombatBox := $"/root/Main Node/Battle Controller/CombatZoneCorner/CombatZone"
@export var CoyoteTime : Timer
@export var JumpRemember : Timer
@export var SlamSfx : AudioStreamPlayer
@export var DingSfx : AudioStreamPlayer
@export var PlayerDamagedSfx : AudioStreamPlayer
@export var HeartShatter : AudioStreamPlayer
@export var HeartSplit : AudioStreamPlayer
@export var ShatterParticles : GPUParticles2D

const SPEED := 450.0
const JUMP_STRENGTH := 700.0

var MaxFallSpeed := 2000.0

var Slammed := false
var SlamDamage := 1

var KR_Counter : float = 0

var Controllable := true

signal died


func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("menu"):
		get_tree().change_scene_to_file("res://Scenes/menu_scene.tscn")
		
	
	
	if Controllable:
		# Get the input direction and handle the movement/deceleration.
		var h_direction := Input.get_axis("left", "right")
		var v_direction := Input.get_axis("up", "down")
		
		
		# Aligns the values to the rotaton of the combatbox before clamping
		## No longer necessary due to the new combat box
		
		#var heart_local_position = CombatBox.to_local(global_position)
		#
		#heart_local_position = heart_local_position.clamp(CombatBox.CboxTopLeft.position + CombatBox.CornerSize * 1.5, CombatBox.CboxBottomRight.position)
		#
		#global_position = CombatBox.to_global(heart_local_position)
		
		#var local_heart_position = CombatBox.transform.basis_xform_inv(global_position)
		#local_heart_position = local_heart_position.clamp(CombatBox.CboxTopLeft.position + CombatBox.CornerSize * 1.5, CombatBox.CboxBottomRight.position - CombatBox.CornerSize * 1.5)
		#
		#position = CombatBox.global_transform.basis_xform(local_heart_position)
		
		#position = position.clamp(CombatBox.CboxTopLeft.global_position + CombatBox.CornerSize * 3, CombatBox.CboxBottomRight.global_position)
		
		match Soul_Type:
			SOUL_RED:
				
				if is_on_wall():
					velocity = Vector2(h_direction, v_direction).normalized() * SPEED 
				else:
					velocity = Vector2(h_direction, v_direction) * SPEED 
				
				
			SOUL_BLUE:
				
				
				# Stops the soul's momentum if the player stops holding jump, really fucking messy
				if ((!v_direction == -1 and gravityDir == 0) or (!v_direction == 1 and gravityDir == 2)) and velocity.rotated(deg_to_rad(gravityDir * -90)).y < -120:
					velocity = Vector2(0, -120).rotated(deg_to_rad(gravityDir * -90))
					
				if ((!h_direction == -1 and gravityDir == 1) or (!h_direction == 1 and gravityDir == 3)) and velocity.rotated(deg_to_rad(gravityDir * 90)).y < -120:
					velocity = Vector2(0, -120).rotated(deg_to_rad(gravityDir * -90))
					
				
				
				if not is_on_floor():
					if Slammed:
						velocity = Vector2(0, MaxFallSpeed).rotated(deg_to_rad(gravityDir * -90))
					else:
						velocity += Vector2(0, gravity * delta).rotated(deg_to_rad(gravityDir * -90))
				if (v_direction == -1 and gravityDir == 0) or (v_direction == 1 and gravityDir == 2) or (h_direction == -1 and gravityDir == 1) or (h_direction == 1 and gravityDir == 3):
					JumpRemember.start()
					
					
				if not CoyoteTime.is_stopped() and not JumpRemember.is_stopped():
					JumpRemember.stop()
					CoyoteTime.stop()
					velocity = Vector2(0, -JUMP_STRENGTH).rotated(deg_to_rad(gravityDir * -90))
					
				if gravityDir in [0, 2]:
					velocity.x = h_direction * SPEED 
				else:
					velocity.y = v_direction * SPEED
				
					
				if is_on_floor():
					CoyoteTime.start()
					
					
		SoulSprite.rotation = rotate_toward(SoulSprite.rotation, deg_to_rad(gravityDir * -90 + 90), delta * 10)
				
		move_and_slide()
		
		if Slammed and is_on_floor():
			SlamHitGround()
		
		
	if Globals.KR == 0:
		KR_Counter = 0
	else:
		KR_Counter += delta
		
	if Globals.KR >= 40 and KR_Counter >= 1.0/30.0:
		KarmaDamage()
	elif Globals.KR >= 30 and KR_Counter >= 2.0/30.0:
		KarmaDamage()
	elif Globals.KR >= 20 and KR_Counter >= 5.0/30.0:
		KarmaDamage()
	elif Globals.KR >= 10 and KR_Counter >= 15.0/30.0:
		KarmaDamage()
	elif KR_Counter >= 1.0:
		KarmaDamage()
		

func KarmaDamage() -> void:
	Globals.KR -= 1
	Globals.HP -= 1
	KR_Counter = 0

func Change_Soul(Type) -> void:
	# TODO Implement additional reasons to not do the animation (such as when flashes are added)
	if Soul_Type != Type and visible:
		DingSfx.play()
		FadeSoulAnim()
	Soul_Type = Type
	match Soul_Type:
		SOUL_RED:
			gravityDir = 0
			motion_mode = MOTION_MODE_FLOATING
			SoulSprite.modulate = Color(1, 0, 0)
		SOUL_BLUE:
			motion_mode = MOTION_MODE_GROUNDED
			SoulSprite.modulate = Color8(0, 60, 255)
			
func SlamHitGround() -> void:
	Slammed = false
	SlamSfx.play()
	if Globals.HP > 0:
		if Globals.HP - SlamDamage > 0:
			if Globals.HP > 1:
				PlayerDamagedSfx.play()
			Globals.HP -= SlamDamage
		else:
			if Globals.HP > 1:
				PlayerDamagedSfx.play()
			Globals.HP = 1
	else:
		PlayerDamagedSfx.play()
		Globals.HP -= SlamDamage

var OldFadeTween : Tween

func FadeSoulAnim():
	if OldFadeTween:
		OldFadeTween.kill()
			
	FadeSprite.scale = Vector2(1, 1)
	FadeSprite.self_modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(FadeSprite, "scale", Vector2(4, 4), 1.5)
	tween.parallel().tween_property(FadeSprite, "self_modulate:a", 0, 1.5)
	
	OldFadeTween = tween
	
func Death():
	Soul_Type = DEAD
	if OldFadeTween:
		OldFadeTween.kill()
	died.emit()
	SoulSprite.modulate = Color(1, 0, 0)
	await Globals.Wait(1)
	HeartSplit.play()
	SoulSprite.texture = SplitSprite
	SoulSprite.modulate = Color.WHITE
	await Globals.Wait(1)
	HeartShatter.play()
	SoulSprite.visible = false
	ShatterParticles.emitting = true
	
func TakeDamage(Damage : int, Karma : int):
	Globals.KR += Karma
	Globals.HP -= Damage
	if Damage > 0 or (Karma > 0 and Globals.HP > 1):
		PlayerDamagedSfx.play()
	
	if Globals.KR >= Globals.HP:
		Globals.KR = Globals.HP - 1
	if Globals.KR > 40:
		Globals.KR = 40
		
	if Globals.HP <= 0 and Soul_Type != DEAD:
		Death()

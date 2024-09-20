extends CharacterBody2D

enum {SOUL_RED, SOUL_BLUE}

var Soul_Type := SOUL_RED

var gravityDir := 0:
	set(d):
		gravityDir = d
		up_direction = Vector2(0, -1).rotated(deg_to_rad(d * -90))

var gravity : float = 980

@onready var SoulSprite := $SoulSprite
@onready var FadeSprite := $SoulSprite/FadeSprite
@onready var CombatBox := $"/root/Main Node/Battle Controller/CombatZone"
@onready var CoyoteTime := $CoyoteTime
@onready var JumpRemember := $JumpRemember

const SPEED := 300.0
const JUMP_STRENGTH := 700.0

var MaxFallSpeed := 2000.0

var Slammed := false
var SlamDamage := 1


func _process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var h_direction := Input.get_axis("left", "right")
	var v_direction := Input.get_axis("up", "down")
	
	if Input.is_action_just_pressed("menu"):
		get_tree().change_scene_to_file("res://Scenes/menu_scene.tscn")
		
	position = position.clamp(CombatBox.CboxTopLeft.global_position + CombatBox.CornerSize * 3, CombatBox.CboxBottomRight.global_position)
	
	
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
				
				
			if Globals.CoolAnimations:
				SoulSprite.rotation = rotate_toward(SoulSprite.rotation, deg_to_rad(gravityDir * -90 + 90), delta * 10)
			else:
				SoulSprite.rotation_degrees = gravityDir * -90 + 90
			
	move_and_slide()
	
	if Slammed and is_on_floor():
		SlamHitGround()
			
	

func Change_Soul(Type) -> void:
	# TODO Implement additional reasons to not do the animation (such as when flashes are added)
	if Soul_Type != Type:
		$Ding.play()
		if Globals.CoolAnimations:
			FadeSoulAnim()
	Soul_Type = Type
	match Soul_Type:
		SOUL_RED:
			motion_mode = MOTION_MODE_FLOATING
			SoulSprite.modulate = Color(1, 0, 0)
		SOUL_BLUE:
			motion_mode = MOTION_MODE_GROUNDED
			SoulSprite.modulate = Color8(0, 60, 255)
			
func SlamHitGround() -> void:
	Slammed = false
	$Slam.play()
	if Globals.HP > 0:
		if Globals.HP - SlamDamage > 0:
			Globals.HP = SlamDamage
		else:
			Globals.HP = 1
	else:
		Globals.HP = SlamDamage
	
func FadeSoulAnim():
	FadeSprite.scale = Vector2(1, 1)
	FadeSprite.self_modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(FadeSprite, "scale", Vector2(4, 4), 1.5)
	tween.parallel().tween_property(FadeSprite, "self_modulate:a", 0, 1.5)
	

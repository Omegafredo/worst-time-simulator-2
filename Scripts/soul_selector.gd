extends Node2D

#var MoveTo : Vector2
#var LerpProgress: float
#var SentSignal : bool = false

var ActiveTweens : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.CoolAnims_Changed.connect(on_cool_anims_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	#if Settings.CoolAnimations:
		#
		#LerpProgress = clampf(delta * 7.5, 0, 1)
		#position = position.lerp(MoveTo, LerpProgress)
		#
		#LerpProgress = clampf(delta * 7.5, 0, 1)
		#position = position.lerp(MoveTo, LerpProgress)
		#if !SentSignal and abs(position.distance_to(MoveTo)) < 2.5:
			#SentSignal = true
			#finished_arrival.emit()
	#else:
		#position = MoveTo
		#if !SentSignal:
			#SentSignal = true
			#finished_arrival.emit()

func InterpolateMovement(GivenPosition : Vector2) -> Tween:
	#SentSignal = false
	#LerpProgress = 0
	#MoveTo = GivenPosition
	if Globals.CoolAnimations:
		var tween = get_tree().create_tween()
		ActiveTweens.append(tween)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(self, "position", GivenPosition, 0.75)
		return tween
	else:
		position = GivenPosition
	return null
	
	
func on_cool_anims_changed():
	for tween in ActiveTweens:
		tween.kill()
	ActiveTweens.clear()
	
	
	
	
	

	
	

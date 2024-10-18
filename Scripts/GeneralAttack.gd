extends Node2D
class_name Attack

var Masked : bool = false:
	set(d):
		if d:
			reparent(MaskedNode)
		else:
			reparent(AttacksNode)
		Masked = d

@onready var Player : CharacterBody2D = get_tree().root.get_node("Main Node").find_child("Player")
@onready var MaskedNode : Node2D = get_tree().root.get_node("Main Node").find_child("MaskedAttacks")
@onready var AttacksNode : Node = get_tree().root.get_node("Main Node").find_child("VisibleAttacks")
@export var Hitbox : Area2D
@export var Damage : int
@export var Karma : int
var PlayerHitboxIn : bool = false
var Counter : float = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Hitbox.body_entered.connect(_body_entered)
	Hitbox.body_exited.connect(_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PlayerHitboxIn:
		Counter += delta
		
		if Counter > 1.0/30.0:
			Counter = 0
			Player.TakeDamage(Damage, Karma)

func _body_entered(body: Node2D):
	if body == Player:
		PlayerHitboxIn = true
		Counter = 0

func _body_exited(body: Node2D):
	if body == Player:
		PlayerHitboxIn = false

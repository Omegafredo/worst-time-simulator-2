extends Node2D
class_name Attack

var BC : BattleController
@onready var Soul : Player = BC.Soul
@onready var MaskedNode : Node2D = BC.MaskedAttacks
@onready var AttacksNode : Node = BC.VisibleAttacks
@export var Hitbox : Area2D
@export var Damage : int
@export var Karma : int
var PlayerHitboxIn : bool = false
var Counter : float = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Hitbox:
		Hitbox.body_entered.connect(_body_entered)
		Hitbox.body_exited.connect(_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PlayerHitboxIn:
		Counter += delta
		
		if Counter > 1.0/30.0:
			Counter = 0
			Soul.TakeDamage(Damage, Karma)
			
func set_masked(state : bool):
	if state:
		reparent(MaskedNode)
	else:
		reparent(AttacksNode)

func get_masked() -> bool:
	if get_parent() == MaskedNode:
		return true
	elif get_parent() != AttacksNode:
		print(self.to_string() + " is not child of a masked/visible node")
	return false

func _body_entered(area_rid : RID, area : Area2D, area_shape_index : int, local_shape_index : int):
	if area == Soul.Hitbox:
		PlayerHitboxIn = true
		Counter = 0

func _body_exited(area_rid : RID, area : Area2D, area_shape_index : int, local_shape_index : int):
	if area == Soul.Hitbox:
		PlayerHitboxIn = false

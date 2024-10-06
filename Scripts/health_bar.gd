extends Sprite2D

@onready var HealthBar := $YellowBar
@onready var KrBar := $Krbar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	scale.x = Globals.MaxHP * 3.6
	HealthBar.scale.x = float(Globals.HP) / float(Globals.MaxHP)
	KrBar.position.x = HealthBar.scale.x
	KrBar.scale.x = -float(Globals.KR) / float(Globals.MaxHP)

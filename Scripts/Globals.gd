extends Node

# Settings variables

var MusicEnabled : bool = true
var ShowIntro : bool = true
var PlayerName := "CHARA"

var CustomMode : bool
var HardMode : bool = false
var NoDeath : bool = false

var MasterBus:
	get():
		return db_to_linear(AudioServer.get_bus_volume_db(0))
	set(d):
		AudioServer.set_bus_volume_db(0, snappedf(linear_to_db(d), 0.01))

var SfxBus:
	get():
		return db_to_linear(AudioServer.get_bus_volume_db(1))
	set(d):
		AudioServer.set_bus_volume_db(1, snappedf(linear_to_db(d), 0.01))

var MusicBus:
	get():
		return db_to_linear(AudioServer.get_bus_volume_db(2))
	set(d):
		AudioServer.set_bus_volume_db(2, snappedf(linear_to_db(d), 0.01))

# Gameplay

var HP := 92:
	get():
		if HP > MaxHP:
			return MaxHP
		return HP
var MaxHP := 92
var KR := 0

var CurrentItems : Array

func _ready():
	var CPie = FoodItem.new()
	CPie.Name = "Pie"
	CPie.Health = 90
	var CNoodles = FoodItem.new()
	CNoodles.Name = "I.Noodles"
	CNoodles.Health = 90
	var CSteak = FoodItem.new()
	CSteak.Name = "Steak"
	CSteak.Health = 60
	var CHero = FoodItem.new()
	CHero.Name = "L.Hero"
	CHero.Health = 40
	
	CurrentItems = [CPie, CNoodles, CSteak, CHero]

# Other

var CustomAttackScript : GDScript


# Functions

func Wait(Seconds) -> void:
	await get_tree().create_timer(Seconds).timeout

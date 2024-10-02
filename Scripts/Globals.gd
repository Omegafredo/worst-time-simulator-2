extends Node

# Settings variables

signal CoolAnims_Changed

var MusicEnabled : bool = true
var CoolAnimations : bool = true:
	set(ca):
		CoolAnimations = ca
		CoolAnims_Changed.emit()
var ShowIntro : bool = true
var PlayerName := "CHARA"

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

var HP := 92
var MaxHP := 92
var KR := 0

# Functions

func Wait(Seconds) -> void:
	await get_tree().create_timer(Seconds).timeout

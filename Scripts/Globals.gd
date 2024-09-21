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

# Gameplay

var HP := 92
var MaxHP := 92

# Functions

func Wait(Seconds) -> void:
	await get_tree().create_timer(Seconds).timeout

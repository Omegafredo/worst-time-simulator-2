extends Node

# Settings

signal CoolAnims_Changed

var MusicEnabled : bool = true
var CoolAnimations : bool = true:
	set(ca):
		CoolAnimations = ca
		CoolAnims_Changed.emit()
var ShowIntro : bool = true

# Gameplay

var HP := 92
var MaxHP := 92

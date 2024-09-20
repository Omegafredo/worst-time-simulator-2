extends Node

func Wait(Seconds) -> void:
	await get_tree().create_timer(Seconds).timeout
	

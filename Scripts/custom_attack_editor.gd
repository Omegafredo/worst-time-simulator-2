extends Control

@onready var SaveButton = $Panel/Save
@onready var CodeEditor = $Panel/CodeEdit
#var CustomCodePath = load("res://CustomCode.gd")


func _on_save_pressed():
	#var CustomCode = CustomCodePath.new()
	#CustomCode.set_source_code(CodeEditor.text)
	#CustomCode.reload()
	#$"../..".set_script(CustomCode)
	
	var CustomCode = GDScript.new()
	CustomCode.set_source_code(CodeEditor.text)
	CustomCode.reload()
	$"../..".set_script(CustomCode)


func _on_button_pressed():
	$"../..".TestFunction()

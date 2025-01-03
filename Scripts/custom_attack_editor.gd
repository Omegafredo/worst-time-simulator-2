extends Control

@onready var CodeEditor = $Panel/VBoxContainer/CodeEdit
@onready var TemplateCode = preload("res://Scripts/attack_template.gd")
@onready var ImportDialog = $ImportDialog
@onready var ExportDialog = $ExportDialog

#var CustomCodePath = load("res://CustomCode.gd")


func _ready():
	if !Globals.CustomAttackScript:
		CodeEditor.text = TemplateCode.new().get_script().get_source_code()
	else:
		CodeEditor.text = Globals.CustomAttackScript.get_source_code()
	

func _on_save_pressed():
	#var CustomCode = CustomCodePath.new()
	#CustomCode.set_source_code(CodeEditor.text)
	#CustomCode.reload()
	#$"../..".set_script(CustomCode)
	
	StringToGlobal(CodeEditor.text)


func _on_test_button_pressed():
	pass

func _on_import_pressed():
	ImportDialog.visible = true
	pass # Replace with function body.


func _on_export_pressed():
	ExportDialog.visible = true
	pass # Replace with function body.


func StringToGlobal(AttackString : String) -> void:
	SaveToGlobal(ToGDScript(AttackString))
	
func SaveToGlobal(AttackScript : GDScript) -> void:
	Globals.CustomAttackScript = AttackScript

func ToGDScript(AttackString : String) -> GDScript:
	var CustomCode : GDScript = GDScript.new()
	CustomCode.set_source_code(AttackString)
	return CustomCode
	
func Import(CodeString : String):
	CodeEditor.text = CodeString
	StringToGlobal(CodeString)


func _on_export_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(CodeEditor.text)

func _on_import_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ)
	Import(file.get_as_text())
	file.close()


func _on_code_edit_text_changed():
	CodeEditor.add_code_completion_option(CodeEdit.KIND_FUNCTION, "GasterBlaster", "BD.GasterBlaster")
	CodeEditor.update_code_completion_options(true)

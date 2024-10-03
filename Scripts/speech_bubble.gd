extends Node2D

enum modes {Default, Serious, TextBox}

const sansFont = preload("res://Resources/Fonts/styles/comicSansVariant.tres")
const sansSerious = preload("res://Resources/Fonts/styles/SansSeriousVariant.tres")
const boxText = preload("res://Resources/Fonts/styles/boxText.tres")

@onready var TextLabel := $RichText
@onready var SansSpeak := $SansSpeak
@onready var BattleText := $BattleText
@onready var ContinueDelay := $ContinueDelay

signal sendInput
signal clearedText
signal receivedInput
signal textDone

@export var CurrentMode : modes
@export var CharacterInterval : float = 0.07
@export var AskForInput := true
var SkippableText := true
var Skipping := false
var Waiting := false
var DontSkipThisFrame := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("accept"):
		sendInput.emit()
	if Input.is_action_just_pressed("cancel") and SkippableText and !DontSkipThisFrame:
		TextLabel.visible_characters = -1
		Skipping = true
		ContinueDelay.stop()
		ContinueDelay.timeout.emit()
	
	DontSkipThisFrame = false
		
func DontSkipDuringThisParticularFrame() -> void:
	DontSkipThisFrame = true
		
func setText(text : String) -> void:
	Skipping = false
	
	TextLabel.text = text
	TextLabel.visible_characters = 0
	if not TextLabel.visible_characters >= TextLabel.get_total_character_count():
		displayChar()
	await get_tree().process_frame
	self.show()
	
func displayChar() -> void:
	if !Skipping:
		if TextLabel.visible_ratio != 1:
			TextLabel.visible_characters += 1
			
			if TextLabel.get_parsed_text()[TextLabel.visible_characters - 1] != " ":
				match CurrentMode:
					modes.Default:
						SansSpeak.play()
					modes.TextBox:
						BattleText.play()
			await Globals.Wait(CharacterInterval)
			displayChar()
		else:
			textDone.emit()
	else:
		await get_tree().process_frame
		textDone.emit()

func clearText() -> void:
	self.hide()
	clearedText.emit()

func hideText() -> void:
	TextLabel.hide()
	TextLabel.visible_characters = -1

func unhideText() -> void:
	TextLabel.show()
	TextLabel.visible_characters = 0
	displayChar()

func continueText(addedText : String, Delay : float = 0.0) -> void:
	Waiting = true
	await textDone
	if !Skipping:
		ContinueDelay.start(Delay)
		await ContinueDelay.timeout
	Waiting = false
	# append_text() doesn't work for some reason
	TextLabel.append_text(addedText)
	#TextLabel.text += addedText
	if not TextLabel.visible_characters >= TextLabel.get_total_character_count():
		displayChar()
	Skipping = false
		
func changeMode(modeChange : int) -> void:
	CurrentMode = modeChange
	
	match modeChange:
		modes.Default:
			TextLabel.add_theme_font_override("normal_font", sansFont)
			TextLabel.add_theme_font_size_override("normal_font_size", 14)
		modes.Serious:
			TextLabel.add_theme_font_override("normal_font", sansSerious)
			TextLabel.add_theme_font_size_override("normal_font_size", 16)
		modes.TextBox:
			TextLabel.add_theme_font_override("normal_font", boxText)
			TextLabel.add_theme_font_size_override("normal_font_size", 96)
	
	

func _on_text_done() -> void:
	if AskForInput:
		if !Waiting:
			await self.sendInput
			if self.visible:
				receivedInput.emit()
				clearText()
			

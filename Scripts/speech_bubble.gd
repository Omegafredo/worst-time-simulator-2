extends Node2D
class_name TextSystem

enum modes {Default, Serious, TextBox}

const sansFont = preload("res://Resources/Fonts/styles/comicSansVariant.tres")
const sansSerious = preload("res://Resources/Fonts/styles/SansSeriousVariant.tres")
const boxText = preload("res://Resources/Fonts/styles/boxText.tres")

@export var TextLabel : RichTextLabel
@onready var SansSpeak := $SansSpeak
@onready var BattleText := $BattleText

signal sendInput
signal clearedText
signal receivedInput
signal textDone

@export var CurrentMode : modes
@export var CharacterInterval : float = 0.07
@export var AskForConfirmation := true
var SkippableText := true
var IsConfirmable := false
var Skipping := false
var CurrentlyTyping := false

var TimeDelay : Array[float]
var AtCharacter : Array[int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("accept"):
		Confirm()
	if Input.is_action_just_pressed("cancel"):
		if SkippableText and TextLabel.visible_characters > 1:
			TextLabel.visible_characters = -1
			Skipping = true
		
		
func setText(text : String) -> void:
	Skipping = false
	
	ClearTextTags()
	
	var ModifiedText = ParseWaitTags(text)
	
	TextLabel.text = ModifiedText
	TextLabel.visible_characters = 0
	if not TextLabel.visible_characters >= TextLabel.get_total_character_count():
		displayChar()
	await get_tree().process_frame
	self.show()


func displayChar() -> void:
	if !Skipping:
		if TextLabel.visible_ratio != 1:
			CurrentlyTyping = true
			TextLabel.visible_characters += 1
			
			if TextLabel.get_parsed_text()[TextLabel.visible_characters - 1] != " ":
				match CurrentMode:
					modes.Default:
						SansSpeak.play()
					modes.TextBox:
						BattleText.play()
			if TextLabel.visible_characters in AtCharacter:
				var i = 0
				for n in AtCharacter:
					if n == TextLabel.visible_characters:
						await Globals.Wait(TimeDelay[i])
						break
					i += 1
			else:
				await Globals.Wait(CharacterInterval)
			displayChar()
		else:
			textDone.emit()
			if AskForConfirmation:
				IsConfirmable = true
			CurrentlyTyping = false
	else:
		await get_tree().process_frame
		textDone.emit()
		CurrentlyTyping = false
	

func clearText() -> void:
	self.hide()
	clearedText.emit()

func hideText() -> void:
	self.hide()
	TextLabel.visible_characters = -1

func unhideText() -> void:
	self.show()
	TextLabel.visible_characters = 0
	Skipping = false
	if !CurrentlyTyping:
		displayChar()
		
func changeMode(modeChange) -> void:
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
	
func Confirm() -> void:
	if IsConfirmable:
		TextConfirmed()

func TextConfirmed() -> void:
	if self.visible:
		receivedInput.emit()
		clearText()
		
func ClearTextTags() -> void:
	TimeDelay.clear()
	AtCharacter.clear()

func ParseWaitTags(TextToParse : String) -> String:
	var WaitSearch = RegEx.create_from_string("(?i)\\[Wait=(\\d+\\.?\\d*)\\]")
	var ModifiedText : String = TextToParse
	var ReduceAmount : int = 0
	for result in WaitSearch.search_all(ModifiedText):
		TimeDelay.append(float(result.strings[-1]))
		AtCharacter.append(result.get_start() - ReduceAmount)
		
		ReduceAmount += result.get_string().length()
		
		ModifiedText = WaitSearch.sub(ModifiedText, "")
	return ModifiedText

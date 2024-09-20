extends Sprite2D

enum {Default, Serious}

var sansFont = preload("res://Resources/Fonts/styles/comicSansVariant.tres")
var eightbit = preload("res://Resources/Fonts/styles/8bitVariant.tres")

@onready var TextLabel := $RichTextLabel
@onready var SansSpeak := $SansSpeak

signal sendInput
signal clearedText
signal receivedInput
signal textDone

var CurrentMode : int = Default
var CharacterInterval : float = 0.07
var AskForInput := true
var SkippableText := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("accept"):
		sendInput.emit()
	if Input.is_action_just_pressed("cancel") and SkippableText:
		TextLabel.visible_ratio = 1.0

func setText(text : String) -> void:
	self.show()
	
	TextLabel.text = text
	TextLabel.visible_characters = 0
	if not TextLabel.visible_characters >= TextLabel.get_total_character_count():
		displayChar()
	
func displayChar() -> void:
	if TextLabel.visible_ratio != 1.0:
		TextLabel.visible_characters += 1
		
		if TextLabel.get_parsed_text()[TextLabel.visible_characters - 1] != " " and CurrentMode == Default:
			SansSpeak.play()
		if not TextLabel.visible_characters >= TextLabel.get_total_character_count():
			await Globals.Wait(CharacterInterval)
			displayChar()
		else:
			textDone.emit()
	else:
		await get_tree().process_frame
		textDone.emit()

func clearText() -> void:
	TextLabel.text = ""
	self.hide()
	clearedText.emit()

func continueText(addedText : String) -> void:
	print(TextLabel.text.length())
	# append_text() doesn't work for some reason
	TextLabel.text += addedText
	print("test4 ", TextLabel.text.length())
	if not TextLabel.visible_characters >= TextLabel.get_total_character_count():
		displayChar()
		
func changeMode(modeChange : int) -> void:
	CurrentMode = modeChange
	
	match modeChange:
		Default:
			TextLabel.add_theme_font_override("normal_font", sansFont)
			TextLabel.add_theme_font_size_override("normal_font_size", 14)
		Serious:
			TextLabel.add_theme_font_override("normal_font", eightbit)
			TextLabel.add_theme_font_size_override("normal_font_size", 16)
	
	

func _on_text_done() -> void:
	if AskForInput:
		await self.sendInput or self.clearedText
		if self.visible:
			receivedInput.emit()
			clearText()
			

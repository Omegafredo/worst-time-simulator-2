extends Sprite2D

@onready var TextLabel := $RichTextLabel
@onready var SansSpeak := $SansSpeak

signal sendInput
signal clearedText
signal receivedInput
signal textDone

var CharacterInterval : float = 0.07
var AskForInput := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("accept"):
		sendInput.emit()
	pass

func setText(text : String) -> void:
	self.show()
	
	TextLabel.text = text
	TextLabel.visible_characters = 0
	if not TextLabel.visible_characters >= TextLabel.text.length():
		displayChar()
	
func displayChar() -> void:
	TextLabel.visible_characters += 1
	
	SansSpeak.play()
	if not TextLabel.visible_characters >= TextLabel.text.length():
		await Global_Func.Wait(CharacterInterval)
		displayChar()
	else:
		print("test2")
		textDone.emit()

func clearText() -> void:
	TextLabel.text = ""
	self.hide()
	clearedText.emit()

func continueText(addedText : String) -> void:
	print(TextLabel.text.length())
	# Append Text doesn't work?
	TextLabel.append_text(addedText)
	print("test4", TextLabel.text.length())
	if not TextLabel.visible_characters >= TextLabel.text.length():
		displayChar()
		print("test5")

func _on_text_done() -> void:
	if AskForInput:
		print("test1")
		await self.sendInput or self.clearedText
		print("test2")
		if self.visible:
			receivedInput.emit()
			clearText()

extends Node2D

var MoveIndex : int = 0
var ControlsAllowed : bool = false
@onready var Soul : Object = %SoulSelector
var CurrentMenu : Object
var CurrentLabel : Object:
	get():
		return CurrentMenu.get_child(MoveIndex)
@onready var MainContainer : Object = $MenuContainer
var Menus : Array
var SideOptions : Array
var SettingsSelections : Array
var MenuHistory : Array
var MenuLabelHistory : Array
var IndexHistory : Array
@onready var MenuCursorSound : Object = $MenuCursor
@onready var MenuSelectSound : Object = $MenuSelect
@onready var MenuLogoSound := $LogoAppear
@onready var FlashSound : Object = $Flash
@onready var WTSLogo : Object = $"/root/Menu Scene/WTS"
@onready var BottomParticles : Object = $"/root/Menu Scene/BottomParticles"
@onready var BottomGradient : Object = $"/root/Menu Scene/BottomGradient"
const SoulOffset : Vector2 = Vector2(-60, 35)

const WTSLogoPosition := Vector2(-625, 25)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Globals.CoolAnims_Changed.connect(on_cool_anims_changed)
	
	
	# Gathers all the Menus into an array
	for child in MainContainer.get_children():
		Menus.append(child)
	
	for menu in Menus:
		for option in menu.get_children():
			if option.SideOption:
				SideOptions.append(option)
	
	# Sets the first menu as the Current Menu
	CurrentMenu = Menus[0]
	
	MenuHistory.append(CurrentMenu)
	
	
	if Globals.ShowIntro:
		Globals.ShowIntro = false
		InitiateIntro()
	else:
		InitiateMenu()
	



var held_time : float
var held_free : bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	
	if ControlsAllowed:
		
		if Input.is_action_just_released("left") or Input.is_action_just_released("right") or (Input.is_action_pressed("left") and Input.is_action_pressed("right")):
			held_time = 0
		
		if Input.is_action_just_pressed("up"):
			MoveAction(-1)
		elif Input.is_action_just_pressed("down"):
			MoveAction(1)
		if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
			@warning_ignore("narrowing_conversion")
			SideOption(Input.get_axis("left", "right"))
		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			held_time += delta
			
			if held_time > 0.45:
				if held_free:
					held_free = false
					await Globals.Wait(0.04)
					@warning_ignore("narrowing_conversion")
					SideOption(Input.get_axis("left", "right") * 2)
					held_free = true
		if Input.is_action_just_pressed("accept"):
			ConfirmAction()
		if Input.is_action_just_pressed("cancel"):
			CancelAction()
		
	


	
# Called when pressing a move action
func MoveAction(Direction : int) -> void:
	MoveSoul(MoveIndex + int(Direction))
	MenuCursorSound.play()

# Called when moving the soul
func MoveSoul(MovingTo : int) -> void:
	
	MoveIndex = MovingTo
	
	if MoveIndex > CurrentMenu.get_child_count() - 1:
		MoveIndex = 0
	elif MoveIndex < 0:
		MoveIndex = CurrentMenu.get_child_count() - 1
	var Total_Gap : float = 0
	var i : int = 0
	for Option in CurrentMenu.get_children():
		i += 1
		if MoveIndex >= i:
			Total_Gap += Option.size.y + 4
	Soul.InterpolateMovement(CurrentMenu.global_position + SoulOffset + Vector2(0, Total_Gap) )
		

func CancelAction() -> void:
	if MenuHistory.size() > 1:
		ReturnMenu()
		MenuSelectSound.play()
		

func ConfirmAction() -> void:
	if CurrentLabel.SideOption == false and CurrentLabel.DeactiveState == false:
		match CurrentLabel.get_name():
			"Start":
				InitiateBattle()
			_:
				if !CurrentLabel.LinkedProperty.is_empty():
					get_node(CurrentLabel.PropertyObject).set(CurrentLabel.LinkedProperty, !get_node(CurrentLabel.PropertyObject).get(CurrentLabel.LinkedProperty))
				elif CurrentLabel.MenuChange != null:
					ChangeMenu(CurrentLabel.MenuChange.name)
		
		UpdateLabels()
		MenuSelectSound.play()

func UpdateLabels() -> void:
	
	
	#find_child("NoMusic").SetActiveState(!Settings.MusicEnabled)
	
	#find_child("CoolAnimations").SetActiveState(Settings.CoolAnimations)
	
	#for child in Global_Func.get_all_children(self):
		#if child is SettingSelection:
			#child.Update()
			
	for child in find_children("*", "SettingSelection", true):
		child.Update()
	
	

func ChangeMenu(MenuTo : String) -> void:
	OldMenuOut()
	CurrentMenu = MainContainer.get_node(MenuTo)
	CurrentMenu.visible = true
	NewMenuIn()
	AppendHistory()
	MoveSoul(0)
	
func ReturnMenu() -> void:
	NewMenuOut()
	CurrentMenu = MenuHistory[-2]
	OldMenuIn()
	#for menu in Menus:
		#menu.visible = false
	#CurrentMenu.visible = true
	MoveSoul(IndexHistory[-1])
	PopHistory()
	
func SideOption(Direction : int) -> void:
	if CurrentLabel in SideOptions:
		if !CurrentLabel.LinkedProperty.is_empty() and CurrentLabel.CheckIfClamp(Direction * CurrentLabel.DirMultiplier) and !CurrentLabel.DeactiveState:
			get_node(CurrentLabel.PropertyObject).set(CurrentLabel.LinkedProperty, get_node(CurrentLabel.PropertyObject).get(CurrentLabel.LinkedProperty) + CurrentLabel.LowerIfNearEdge(Direction * CurrentLabel.DirMultiplier))
			MenuSelectSound.play()
		
		UpdateLabels()
	
func InitiateBattle() -> void:
	if Globals.CoolAnimations:
		ControlsAllowed = false
		for i in range(4):
			await Flash(true)
			await Flash(false)
		Flash(true)
		var tween = Soul.InterpolateMovement(Vector2(1000, 1000))
		await tween.finished
	Globals.HP = Globals.MaxHP
	Globals.KR = 0
	request_ready()
	get_tree().change_scene_to_file("res://Scenes/battle_scene.tscn")
	
func InitiateIntro() -> void:
	if Globals.CoolAnimations:
		MainContainer.hide()
		Soul.hide()
		WTSLogo.hide()
		await Globals.Wait(3)
		WTSLogo.show()
		MenuLogoSound.play()
		await Globals.Wait(1)
		InterpolateObject(WTSLogo, "position:y", WTSLogoPosition.y, 1, Tween.EASE_OUT, Tween.TRANS_EXPO)
		await Globals.Wait(0.75)
		MainContainer.show()
		InterpolateObject(BottomGradient, "modulate:a", 1, 2, Tween.EASE_IN_OUT, Tween.TRANS_QUAD)
		BottomParticles.emitting = true
		for Option in CurrentMenu.get_children():
			Option.position.y = 1700
		var Total_Gap : float = 0
		for Option in CurrentMenu.get_children():
			InterpolateObject(Option, "position:y", Total_Gap, 1, Tween.EASE_OUT, Tween.TRANS_EXPO)
			Total_Gap += Option.size.y + 4
			await Globals.Wait(0.07)
			
		Soul.show()
		Soul.position = Vector2(CurrentMenu.global_position.x + SoulOffset.x, 1700)
		MenuSway()
		var tween = Soul.InterpolateMovement(CurrentMenu.global_position + SoulOffset)
		await tween.finished
		
	else:
		WTSLogo.position = WTSLogoPosition
		BottomGradient.modulate.a = 1
		BottomGradient.hide()
		Soul.position = CurrentMenu.global_position + SoulOffset
	
	ControlsAllowed = true
	
func InitiateMenu() -> void:
	Soul.show()
	WTSLogo.show()
	MainContainer.show()
	BottomGradient.visible = Globals.CoolAnimations
	BottomParticles.emitting = Globals.CoolAnimations
	BottomParticles.preprocess = 2
	WTSLogo.position = WTSLogoPosition
	BottomGradient.modulate.a = 1
	Soul.position = CurrentMenu.global_position + SoulOffset
	ControlsAllowed = true
	
	if Globals.CoolAnimations:
		MenuSway()
	
	
	# Applies all label changes when coming back from a battle
	UpdateLabels()
	
func on_cool_anims_changed():
	BottomParticles.emitting = Globals.CoolAnimations
	BottomGradient.visible = Globals.CoolAnimations
	
	
	if Globals.CoolAnimations:
		MenuSway()
	else:
		#Soul.InterpolateMovement(CurrentMenu.get_child(MoveIndex).global_position + SoulOffset)
		MenuSwayStop()
	
var MenuSwayTween : Tween
var MenuSwayTime : float = 3
var MenuSwayAmount : float = 2.5
	
func MenuSway() -> void:
	var tween = WTSLogo.create_tween()
	MenuSwayTween = tween
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_loops()
	tween.tween_property(WTSLogo, "rotation_degrees", MenuSwayAmount, MenuSwayTime)
	tween.tween_property(WTSLogo, "rotation_degrees", -MenuSwayAmount, MenuSwayTime)

func MenuSwayStop() -> void:
	WTSLogo.rotation_degrees = 0
	MenuSwayTween.kill()
	
func AppendHistory() -> void:
	MenuHistory.append(CurrentMenu)
	IndexHistory.append(MoveIndex)

func PopHistory() -> void:
	MenuHistory.pop_back()
	IndexHistory.pop_back()
	MenuLabelHistory.pop_back()
	
func InterpolateObject(MovedObject : Object, Property : String, Value, Duration : float, Ease : Tween.EaseType, Trans : Tween.TransitionType) -> Tween:
	var tween = get_tree().create_tween()
	tween.set_ease(Ease)
	tween.set_trans(Trans)
	tween.tween_property(MovedObject, Property, Value, Duration)
	return tween

func Flash(Toggle : bool) -> void:
	if Toggle:
		FlashSound.play()
		MainContainer.hide()
		WTSLogo.hide()
		BottomGradient.hide()
		BottomParticles.hide()
	else:
		FlashSound.play()
		MainContainer.show()
		WTSLogo.show()
		BottomGradient.show()
		BottomParticles.show()
	await Globals.Wait(0.0766)
	
func OldMenuOut() -> void:
	if Globals.CoolAnimations:
		for child in CurrentMenu.get_children():
			if child != CurrentLabel:
				InterpolateObject(child, "position:x", -500, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
				InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		InterpolateObject(CurrentLabel, "position:y", -75, 0.75, Tween.EASE_OUT, Tween.TRANS_BACK)
		if MenuLabelHistory.size() >= 1:
			InterpolateObject(MenuLabelHistory[-1], "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	else:
		CurrentLabel.position.y = -75
		for child in CurrentMenu.get_children():
			if child != CurrentLabel:
				child.modulate.a = 0
		if MenuLabelHistory.size() >= 2:
			MenuLabelHistory[-1].modulate.a = 0
	MenuLabelHistory.append(CurrentLabel)

func OldMenuIn() -> void:
	if Globals.CoolAnimations:
		for child in CurrentMenu.get_children():
			if child != MenuLabelHistory[-1]:
				child.modulate.a = 0
				child.position.x = -300
				InterpolateObject(child, "position:x", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
				InterpolateObject(child, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		if MenuLabelHistory.size() >= 2:
			InterpolateObject(MenuLabelHistory[-2], "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	else:
		for child in CurrentMenu.get_children():
			if child != MenuLabelHistory[-1]:
				child.modulate.a = 1
				child.position.x = 0
		if MenuLabelHistory.size() >= 2:
			MenuLabelHistory[-2].modulate.a = 1

func NewMenuIn() -> void:
	if Globals.CoolAnimations:
		for child in CurrentMenu.get_children():
			child.modulate.a = 0
			child.position.x = 300
			InterpolateObject(child, "position:x", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
			InterpolateObject(child, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	else:
		for child in CurrentMenu.get_children():
			child.modulate.a = 1
			child.position.x = 0
	
func NewMenuOut() -> void:
	var Total_Gap : float = 0
	var i : int = 0
	if Globals.CoolAnimations:
		for child in CurrentMenu.get_children():
			if child != MenuLabelHistory[-1]:
				InterpolateObject(child, "position:x", 500, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
				InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		for Option in MenuHistory[-2].get_children():
			if i == IndexHistory[-1]:
				InterpolateObject(MenuLabelHistory[-1], "position:y", Total_Gap, 1, Tween.EASE_OUT, Tween.TRANS_EXPO)
			Total_Gap += Option.size.y + 4
			i += 1
	else:
		for child in CurrentMenu.get_children():
			if child != MenuLabelHistory[-1]:
				child.modulate.a = 0
		for Option in CurrentMenu.get_children():
			if i == IndexHistory[-1]:
				MenuLabelHistory[-1].position.y = Total_Gap
			Total_Gap += Option.size.y + 4
			i += 1

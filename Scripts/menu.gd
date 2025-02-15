extends Node2D

var MoveIndex : int = 0

enum {StartingBattle, IntroAnim, CodeFocused}
var ControlsBlocked : Array[int]
@onready var Soul : Node2D = %SoulSelector
var CurrentMenu : Menu
var CurrentLabel : SettingSelection:
	get():
		return get_menu_selections()[MoveIndex]
@onready var MainContainer : Node2D = $MenuContainer
var Menus : Array[Menu]
var SideOptions : Array[SettingSelection]
var MenuHistory : Array[Menu]
var MenuLabelHistory : Array[SettingSelection]
var IndexHistory : Array[int]
@onready var MenuCursorSound : AudioStreamPlayer = $MenuCursor
@onready var MenuSelectSound : AudioStreamPlayer = $MenuSelect
@onready var MenuLogoSound : AudioStreamPlayer = $LogoAppear
@onready var FlashSound : AudioStreamPlayer = $Flash
@onready var WTSLogo : TextureRect = $"/root/Menu Scene/WTS"
@onready var BottomParticles : GPUParticles2D = $"/root/Menu Scene/BottomParticles"
@onready var BottomGradient : TextureRect = $"/root/Menu Scene/BottomGradient"

var OriginalSelectPos : Dictionary
const SoulOffset : Vector2 = Vector2(-60, 35)

const WTSLogoPosition := Vector2(-625, 25)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.FirstTime:
		LoadMods()
		Globals.FirstTime = false
	
	
	# Gathers all the Menus into an array
	for child in MainContainer.get_children():
		Menus.append(child)
	
	# Adds custom fights to the custom fight menu
	var dir = DirAccess.open("res://")
	var i : int = 0
	if dir.dir_exists("Custom Fights"):
		dir.change_dir("Custom Fights")
		for a in dir.get_files():
			var res = load(dir.get_current_dir() + "/" + a)
			print(dir.get_current_dir() + "/" + a)
			print(res)
			if a.get_extension() in ["gd", "gdc"]:
				var CFButton = SettingSelection.new()
				CFButton.activated.connect(_on_custom_start.bind(res))
				CFButton.position = Vector2(61, i * 70)
				CFButton.text = a
				CFButton.label_settings = load("res://Resources/Fonts/styles/menu_label.tres")
				$MenuContainer/CustomAttacks.add_child(CFButton)
				
				i += 1
	else:
		print("fuck you")
	if i == 0:
		$MenuContainer/FirstMenu/CustomAttack.DeactiveState = true
		UpdateLabels()
	
	for menu in Menus:
		for option in menu.get_children():
			if option is SettingScroll:
				SideOptions.append(option)
		for selection in get_menu_selections(menu):
			OriginalSelectPos[selection] = selection.global_position
	
	# Sets the first menu as the Current Menu
	CurrentMenu = Menus[0]
	
	MenuHistory.append(CurrentMenu)
	

	
	
	if Globals.ShowIntro:
		Globals.ShowIntro = false
		InitiateIntro()
	else:
		InitiateMenu()
		if Globals.CustomMode:
			ChangeMenu($MenuContainer/CustomAttacks, $MenuContainer/FirstMenu/CustomAttack)
			
	MoveIndex = get_top_active_index()
	



var held_time : float
var held_free : bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	
	if ControlsBlocked.is_empty():
		
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
	var TempIndex = MoveIndex
	while true:
		if Direction == 0:
			Direction = 1
		TempIndex += Direction
		
		if TempIndex > get_menu_selections().size() - 1:
			return
		elif TempIndex < 0:
			return
		
		if !get_menu_selections()[TempIndex].DeactiveState:
			break
	MoveSoul(TempIndex)
	if get_menu_selections().size() > 1:
		MenuCursorSound.play()

# Called when moving the soul
func MoveSoul(MovingTo : int) -> void:
	
	MoveIndex = MovingTo
	
	if MoveIndex > get_menu_selections().size() - 1:
		MoveIndex = 0
	elif MoveIndex < 0:
		MoveIndex = get_menu_selections().size() - 1
	
	# Checks if the label has a original pos saved in the dictionary, if not move directly to its position
	if OriginalSelectPos.has(CurrentLabel):
		Soul.InterpolateMovement(OriginalSelectPos[CurrentLabel] + SoulOffset)
	else:
		Soul.InterpolateMovement(CurrentLabel.global_position + SoulOffset)
		

func CancelAction() -> void:
	if MenuHistory.size() > 1:
		ReturnMenu()
		MenuSelectSound.play()
		

func ConfirmAction() -> void:
	if CurrentLabel is not SettingScroll and CurrentLabel.DeactiveState == false:
		CurrentLabel.activated.emit()
		if CurrentLabel is SettingToggler:
			get_node(CurrentLabel.PropertyObject).set(CurrentLabel.LinkedProperty, !get_node(CurrentLabel.PropertyObject).get(CurrentLabel.LinkedProperty))
		elif CurrentLabel is SettingMenuChanger:
			ChangeMenu(CurrentLabel.MenuChange)
		
		UpdateLabels()
		MenuSelectSound.play()

func _on_start():
	Globals.CustomMode = false
	InitiateBattle()


func _on_custom_start(FightScript : GDScript):
	Globals.CustomMode = true
	Globals.CustomAttackScript = FightScript
	InitiateBattle()

func _on_customattack_menu(HeaderPos : Marker2D, Header : SettingMenuChanger, Movables : Array[Node]):
	#var CustomAttackEditor : Control = Movables[0]
	
	CurrentMenu.visible = true
	CurrentMenu.HideAfter = false
	for child in get_menu_selections():
		child.modulate.a = 0
		child.global_position.x = -300
		InterpolateObject(child, "position:x", 61, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		InterpolateObject(child, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
	
	
		
	#InterpolateObject(CustomAttackEditor, "position:x", 461, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	#InterpolateObject(CustomAttackEditor, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
	var MovedMenu = Header
	var oldTween = MovedMenu.get_meta("ActiveTween")
	if oldTween:
		if oldTween.is_valid():
			oldTween.kill()
	var tween = InterpolateObject(MovedMenu, "global_position", HeaderPos.global_position, 0.75, Tween.EASE_OUT, Tween.TRANS_BACK)
	MovedMenu.set_meta("ActiveTween", tween)
	MenuLabelHistory.append(MovedMenu)

func _on_customattack_exit(Movables : Array[Node]):
	#var Selections : Array[SettingSelection]
	#for Movable in Movables:
		#if Movable is SettingSelection:
			#Selections.append(Movable)
			
	
	CurrentMenu.HideAfter = true
	for child in get_menu_selections():
		if child != MenuLabelHistory[-1]:
			if child is SettingSelection:
				InterpolateObject(child, "global_position:x", -300, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
			InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
	#InterpolateObject(CustomAttackEditor, "position:x", 1000, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	#InterpolateObject(CustomAttackEditor, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
	var TopMenu = MenuLabelHistory[-1]
	
	var oldTween = TopMenu.get_meta("ActiveTween")
	if oldTween:
		if oldTween.is_valid():
			oldTween.kill()
	var tween = InterpolateObject(TopMenu, "global_position", OriginalSelectPos[TopMenu], 1, Tween.EASE_OUT, Tween.TRANS_EXPO)
	TopMenu.set_meta("ActiveTween", tween)
	
	
	
func UpdateLabels() -> void:
	for child in find_children("*", "SettingSelection", true):
		child.Update()
	
	

func ChangeMenu(MenuTo : Menu, MenuHeader : SettingMenuChanger = CurrentLabel) -> void:
	OldMenuOut(MenuHeader)
	if !MenuTo.CustomMenu:
		HeaderIn(MenuHeader)
	CurrentMenu = MenuTo
	MenuTo.Enter(MenuHeader)
	if !MenuTo.CustomMenu:
		NewMenuIn()
	MoveIndex = MenuHeader.get_index()
	AppendHistory()
	MoveSoul(get_top_active_index())
	
	
func ReturnMenu() -> void:
	CurrentMenu.Exit()
	if !CurrentMenu.CustomMenu:
		NewMenuOut()
		HeaderOut()
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
	AssignEnumArray(ControlsBlocked, StartingBattle)
	for i in range(4):
		await Flash(true)
		await Flash(false)
	Flash(true)
	var tween = Soul.InterpolateMovement(Vector2(1000, 1000))
	await tween.finished
	ResetVariables()
	request_ready()
	get_tree().change_scene_to_file("res://Scenes/battle_scene.tscn")
	
func InitiateIntro() -> void:
	ControlsBlocked.append(IntroAnim)
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
	var tween = Soul.InterpolateMovement(CurrentMenu.global_position + Vector2(0, get_top_active_index() * 70) + SoulOffset)
	await tween.finished
	
	
	ControlsBlocked.erase(IntroAnim)
	
func InitiateMenu() -> void:
	Soul.show()
	WTSLogo.show()
	MainContainer.show()
	BottomGradient.visible = true
	BottomParticles.emitting = true
	BottomParticles.preprocess = 2
	WTSLogo.position = WTSLogoPosition
	BottomGradient.modulate.a = 1
	Soul.position = CurrentMenu.global_position + SoulOffset
	ControlsBlocked.clear()
	
	MenuSway()
	
	
	# Applies all label changes when coming back from a battle
	UpdateLabels()


func LoadMods() -> void:
	var mods : Array[String]
	
	const ModFolderPath : String = "mods"
	
	var dir = DirAccess.open(OS.get_executable_path().get_base_dir())
	if dir.dir_exists(ModFolderPath) != null:
		dir.change_dir(ModFolderPath)
		print("found mods folder")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Checks if it is not a folder and it ends in .PCK
			if !dir.current_is_dir() and file_name.get_extension() in ["pck", "zip"]:
				mods.append(dir.get_current_dir() + "/" + file_name)
				print(dir.get_current_dir() + "/" + file_name)
			file_name = dir.get_next()
	else:
		print("couldn't")
	if mods:
		for mod in mods:
			print(ProjectSettings.load_resource_pack(mod))

func ResetVariables() -> void:
	Globals.ResetInventory()
	Globals.HP = Globals.MaxHP
	Globals.KR = 0

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
	var tween = MovedObject.create_tween()
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
	
func OldMenuOut(MovedMenu : SettingMenuChanger) -> void:
	for child in CurrentMenu.get_children():
		if child != MovedMenu:
			InterpolateObject(child, "position:x", -500, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
			InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
			

	
func HeaderIn(MovedMenu : SettingMenuChanger) -> void:
	# Kills the old tween attached to the meta data when creating a new one
	var oldTween = MovedMenu.get_meta("ActiveTween")
	if oldTween:
		if oldTween.is_valid():
			oldTween.kill()
	var tween = InterpolateObject(MovedMenu, "position:y", -75, 0.75, Tween.EASE_OUT, Tween.TRANS_BACK)
	MovedMenu.set_meta("ActiveTween", tween)
	
	if MenuLabelHistory.size() >= 1:
		InterpolateObject(MenuLabelHistory[-1], "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	MenuLabelHistory.append(MovedMenu)
	

func OldMenuIn() -> void:
	CurrentMenu.visible = true
	for child in CurrentMenu.get_children():
		if child != MenuLabelHistory[-1]:
			child.modulate.a = 0
			child.position.x = -300
			InterpolateObject(child, "position:x", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
			InterpolateObject(child, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	if MenuLabelHistory.size() >= 2:
		InterpolateObject(MenuLabelHistory[-2], "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)

func NewMenuIn() -> void:
	CurrentMenu.visible = true
	CurrentMenu.HideAfter = false
	for child in CurrentMenu.get_children():
		child.modulate.a = 0
		child.position.x = 300
		InterpolateObject(child, "position:x", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		InterpolateObject(child, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)


func NewMenuOut() -> void:

	CurrentMenu.HideAfter = true
	for child in CurrentMenu.get_children():
		if child != MenuLabelHistory[-1]:
			InterpolateObject(child, "position:x", 500, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
			InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)

		
func HeaderOut() -> void:
	var Total_Gap : float = 0
	var i : int = 0
	for Option in MenuHistory[-2].get_children():
		if i == IndexHistory[-1]:
			var TopMenu = MenuLabelHistory[-1]
			
			var oldTween = TopMenu.get_meta("ActiveTween")
			if oldTween:
				if oldTween.is_valid():
					oldTween.kill()
			var tween = InterpolateObject(TopMenu, "position:y", Total_Gap, 1, Tween.EASE_OUT, Tween.TRANS_EXPO)
			TopMenu.set_meta("ActiveTween", tween)
		Total_Gap += Option.size.y + 4
		i += 1	


func get_menu_selections(TheMenu : Menu = CurrentMenu) -> Array[SettingSelection]:
	var setting_array : Array[SettingSelection]
	for Selection in TheMenu.get_children():
		if Selection is SettingSelection:
			setting_array.append(Selection)
	return setting_array
	
func get_top_active_index() -> int:
	var i : int = 0
	while true:
		if get_menu_selections().size() - 1 < i:
			return 0
		
		if !get_menu_selections()[i].DeactiveState:
			break
		i += 1
		
	return i

func AssignEnumArray(AssignedArray : Array[int], AssignedInt : int) -> void:
	if not AssignedArray.has(AssignedInt):
		AssignedArray.append(AssignedInt)

func _on_CustomAttackFocused():
	AssignEnumArray(ControlsBlocked, CodeFocused)

func _on_CustomAttackUnfocused():
	ControlsBlocked.erase(CodeFocused)

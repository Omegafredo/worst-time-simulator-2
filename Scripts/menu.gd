extends Node2D

var MoveIndex : int = 0

enum {StartingBattle, IntroAnim, CodeFocused}
var ControlsBlocked : Array[int]
@export var Soul : MenuSoul
var CurrentMenu : Menu
var CurrentLabel : SettingSelection:
	get():
		return get_menu_selections()[MoveIndex]
@export var MainContainer : Node2D
var Menus : Array[Menu]
var SideOptions : Array[SettingSelection]
var MenuHistory : Array[Menu]
var MenuLabelHistory : Array[SettingSelection]
var IndexHistory : Array[int]
@export var MenuCursorSound : AudioStreamPlayer
@export var MenuSelectSound : AudioStreamPlayer
@export var MenuLogoSound : AudioStreamPlayer
@export var FlashSound : AudioStreamPlayer
@export var MenuMusic : AudioStreamPlayer
@export var WTSLogo : TextureRect
@export var BottomParticles : GPUParticles2D
@export var BottomGradient : TextureRect


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
			#print(dir.get_current_dir() + "/" + a)
			#print(res)
			if a.get_extension() in ["gd", "gdc"]:
				var CFButton = SettingSelection.new()
				CFButton.activated.connect(_on_custom_start.bind(res))
				CFButton.position = Vector2(61, 55 + (i % CUSTOM_ATTACK_ROWS * 70))
				CFButton.modulate.a = 0
				CFButton.text = a
				CFButton.label_settings = load("res://Resources/Fonts/styles/menu_label.tres")
				$MenuContainer/CustomAttacks.add_child(CFButton)
				
				i += 1
	else:
		print("Custom Fights folder doesn't exist")
	if i == 0:
		$MenuContainer/FirstMenu/CustomAttack.DeactiveState = true
		UpdateLabels()
	
	for menu in Menus:
		for option in menu.get_children():
			if option is SettingScroll:
				SideOptions.append(option)
			if option is Control:
				OriginalSelectPos[option] = option.global_position
		#for selection in get_menu_selections(menu):
			#OriginalSelectPos[selection] = selection.global_position
	
	# Sets the first menu as the Current Menu
	CurrentMenu = Menus[0]
	
	MenuHistory.append(CurrentMenu)
	

	
	
	if Globals.ShowIntro:
		Globals.ShowIntro = false
		InitiateIntro()
	else:
		InitiateMenu()
		if Globals.CustomPos >= 0:
			var CustomAttacksTitle : SettingMenuChanger = $MenuContainer/FirstMenu/CustomAttack
			var CustomAttacksMenu : Menu = $MenuContainer/CustomAttacks
			ChangeMenu(CustomAttacksMenu, CustomAttacksTitle)
			
			# Not using MoveSoul() here to prevent the animation from happening. Might turn into a function later
			MoveIndex = Globals.CustomPos
			Soul.position = OriginalSelectPos[CurrentLabel] + SoulOffset
			Soul.InterpolateMovement(OriginalSelectPos[CurrentLabel] + SoulOffset)
			
			update_customattack_page_count()
			
			var CAMpos : Vector2 = CustomAttacksMenu.get_node("Marker2D").global_position
			
			# Prevents the CustomAttack title from being animated when returning from an attack
			CustomAttacksTitle.global_position = CAMpos
			InterpolateObject(CustomAttacksTitle, "global_position", CAMpos, 0.75, Tween.EASE_OUT, Tween.TRANS_BACK)
			
			#if floor(MoveIndex / CUSTOM_ATTACK_ROWS) > 0:
			for child in get_menu_selections():
				if child in get_attack_column(MoveIndex / CUSTOM_ATTACK_ROWS):
					child.modulate.a = 1
				else:
					child.modulate.a = 0
					InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
				# Prevents the Custom Attack menu pages from being animated when returning from an attack
				child.global_position = OriginalSelectPos[child]
				InterpolateObject(child, "global_position", OriginalSelectPos[child], 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
			for child in MenuHistory[-2].get_children():
				if child == MenuLabelHistory[-1]:
					continue
				# Prevents the FirstMenu (Start, Settings etc...) menu from being animated when changing to the Custom Menu after returning from an attack
				child.modulate.a = 0
				InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
						
	
	if Globals.CustomPos < 0:
		MoveIndex = get_top_active_index()
	Globals.CustomPos = -1



var held_time : float
var held_free : bool = true


func _input(event: InputEvent) -> void:
	if event.is_action("left") or event.is_action("right"):
		if CurrentMenu == $MenuContainer/CustomAttacks and Input.get_axis("left", "right") != 0:
			move_custom_attack_columns(Input.get_axis("left", "right"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	
	if ControlsBlocked.is_empty():
		
		if Input.is_action_just_released("left") or Input.is_action_just_released("right") or (Input.is_action_pressed("left") and Input.is_action_pressed("right")):
			held_time = 0
		
		if Input.is_action_just_pressed("up"):
			if not CurrentMenu == $MenuContainer/CustomAttacks or MoveIndex % get_attack_column(get_current_attack_column()).size() != 0:
				MoveAction(-1)
		elif Input.is_action_just_pressed("down"):
			
			if not CurrentMenu == $MenuContainer/CustomAttacks or MoveIndex % get_attack_column(get_current_attack_column()).size() != get_attack_column(get_current_attack_column()).size() - 1:
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
	InitiateBattle()


func _on_custom_start(FightScript : GDScript):
	Globals.CustomPos = MoveIndex
	Globals.CustomAttackScript = FightScript
	InitiateBattle()
	
const CUSTOM_ATTACK_ROWS = 10

func get_current_attack_column() -> int:
	return floor(MoveIndex / CUSTOM_ATTACK_ROWS)

func get_attack_column(column : int) -> Array[SettingSelection]:
	var tempArray : Array[SettingSelection]
	
	for i in range(CUSTOM_ATTACK_ROWS):
		var child = get_menu_selections().get(column * (CUSTOM_ATTACK_ROWS) + i)
		if child:
			tempArray.append(child)
	return tempArray
	

func move_custom_attack_columns(direction : int):
	var currentColumn = get_current_attack_column()
	
	if currentColumn == 0 and direction < 0:
		return
	
	if get_attack_column(currentColumn + 1) == [] and direction > 0:
		return
	
	if MoveIndex + CUSTOM_ATTACK_ROWS > get_menu_selections().size() - 1 and direction > 0:
		MoveAction(get_menu_selections().size() - 1 - MoveIndex)
	else:
		MoveAction(CUSTOM_ATTACK_ROWS * direction)
	
	update_customattack_page_count()
	
	currentColumn = get_current_attack_column()
	
	for child in get_attack_column(currentColumn - direction):
		InterpolateObject(child, "global_position:x", -500 * direction + 61, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
	
	for child in get_attack_column(currentColumn):
		child.modulate.a = 0
		child.global_position.x = -500 * -direction + 61
		InterpolateObject(child, "position:x", 61, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		InterpolateObject(child, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)

#func move_custom_attacks_columns_visual(currentColumn : int, direction : float):
	#for i in range(int(ceil(float(get_menu_selections().size()) / float(CUSTOM_ATTACK_ROWS)))):
		#print(int(ceil(float(get_menu_selections().size()) / float(CUSTOM_ATTACK_ROWS))))
		#if i == currentColumn: continue
		#for child in get_attack_column(i):
			#InterpolateObject(child, "global_position:x", -500 * direction + 61, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
			#InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	#
	#
	#for child in get_attack_column(currentColumn):
		#child.modulate.a = 0
		#child.global_position.x = -500 * -direction + 61
		#InterpolateObject(child, "position:x", 61, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		#InterpolateObject(child, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)

func update_customattack_page_count() -> void:
	var PageCounter : Label = $MenuContainer/CustomAttacks/PageCounter
	# Gets the amount of pages there are in total
	if ceil(float(get_menu_selections().size()) / float(CUSTOM_ATTACK_ROWS)) > 1:
		PageCounter.text = "PAGE " + str(get_current_attack_column() + 1)
		PageCounter.show()
	else:
		PageCounter.hide()

func _on_customattack_menu(HeaderPos : Marker2D, Header : SettingMenuChanger, Movables : Array[Node]):
	#var CustomAttackEditor : Control = Movables[0]
	
	CurrentMenu.visible = true
	var i : int = 0
	for child in get_menu_selections():
		if i > CUSTOM_ATTACK_ROWS - 1:
			break
		child.modulate.a = 0
		child.global_position.x = -300
		InterpolateObject(child, "position:x", 61, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		InterpolateObject(child, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		i += 1
	
	MoveIndex = 0
	update_customattack_page_count()
	
	Movables[0].global_position.x = -300
	Movables[0].modulate.a = 0
	InterpolateObject(Movables[0], "global_position:x", OriginalSelectPos[Movables[0]].x, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	InterpolateObject(Movables[0], "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
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
			
	
	for child in get_menu_selections():
		if child != MenuLabelHistory[-1]:
			if child is SettingSelection:
				InterpolateObject(child, "global_position:x", -300, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
			InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
	InterpolateObject(Movables[0], "global_position:x", -300, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	InterpolateObject(Movables[0], "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
	#InterpolateObject(CustomAttackEditor, "position:x", 1000, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	#InterpolateObject(CustomAttackEditor, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
	var TopMenu = MenuLabelHistory[-1]
	
	var oldTween = TopMenu.get_meta("ActiveTween")
	if oldTween:
		if oldTween.is_valid():
			oldTween.kill()
	var tween = InterpolateObject(TopMenu, "global_position", OriginalSelectPos[TopMenu], 1, Tween.EASE_OUT, Tween.TRANS_EXPO)
	TopMenu.set_meta("ActiveTween", tween)
	
func _on_credits_menu_entered(HeaderPos : Marker2D, Header : SettingMenuChanger, Movables : Array[Node]) -> void:
	var CreditsMenu = CurrentMenu
	CreditsMenu.visible = true
	
	
	for child in Movables:
		
		if child in [Movables[0], Movables[2], Movables[4]]:
			child.global_position.x = OriginalSelectPos[child].x - 400
		elif child in [Movables[1], Movables[3], Movables[5]]:
			child.global_position.x = OriginalSelectPos[child].x + 400
		child.modulate.a = 0
	
	InterpolateObject(Soul, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		
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
	
	#var cycles : int = 0
	for child in Movables:
		InterpolateObject(child, "global_position:x", OriginalSelectPos[child].x, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		InterpolateObject(child, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		#cycles += 1
		# Waits for 0.2 seconds and if the CreditsMenu changes to off or exiting during that, abort the function
		var timePos = Time.get_ticks_msec() + (0.2 * 1000)
		while Time.get_ticks_msec() < timePos:
			await get_tree().process_frame
			if CreditsMenu.currentState in [Menu.STATES.off, Menu.STATES.exiting]:
				#print("interrupted after " + str(cycles) + " cycles")
				return
		

			
	if CreditsMenu.currentState == Menu.STATES.entering:
		CreditsMenu.currentState = Menu.STATES.on
	
	


func _on_credits_menu_exited(Movables : Array[Node]) -> void:
	#CurrentMenu.HideAfter = true
	
	#InterpolateObject(CustomAttackEditor, "position:x", 1000, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	#InterpolateObject(CustomAttackEditor, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
	InterpolateObject(Soul, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
	var TopMenu = MenuLabelHistory[-1]
	
	var oldTween = TopMenu.get_meta("ActiveTween")
	if oldTween:
		if oldTween.is_valid():
			oldTween.kill()
	var tween = InterpolateObject(TopMenu, "global_position", OriginalSelectPos[TopMenu], 1, Tween.EASE_OUT, Tween.TRANS_EXPO)
	TopMenu.set_meta("ActiveTween", tween)
	
	for child in Movables:
		if child in [Movables[0], Movables[2], Movables[4]]:
			InterpolateObject(child, "global_position:x", OriginalSelectPos[child].x - 400, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		if child in [Movables[1], Movables[3], Movables[5]]:
			InterpolateObject(child, "global_position:x", OriginalSelectPos[child].x + 400, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		InterpolateObject(child, "modulate:a", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
	
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
	InterpolateObject(MenuMusic, "volume_linear", 0, 1.5, Tween.EASE_OUT, Tween.TRANS_CIRC)
	#InterpolateObject(MenuMusic, "pitch_scale", 0.9, 1.5, Tween.EASE_OUT, Tween.TRANS_CIRC)
	
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
	
	MenuMusic.volume_linear = 0
	MenuMusic.play()
	InterpolateObject(MenuMusic, "volume_linear", 0.2, 10, Tween.EASE_IN, Tween.TRANS_CIRC)
	
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
	MenuMusic.play(40)
	
	MenuSway()
	
	
	# Applies all label changes when coming back from a battle
	UpdateLabels()


func LoadMods() -> void:
	var mods : Array[String]
	
	const ModFolderPath : String = "mods"
	
	var dir = DirAccess.open(OS.get_executable_path().get_base_dir())
	if dir.dir_exists(ModFolderPath) != null:
		dir.change_dir(ModFolderPath)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Checks if it is not a folder and it ends in .PCK
			if !dir.current_is_dir() and file_name.get_extension() in ["pck", "zip"]:
				mods.append(dir.get_current_dir() + "/" + file_name)
				print(dir.get_current_dir() + "/" + file_name)
			file_name = dir.get_next()
	else:
		print("Mods folder does not exist")
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
	for child in CurrentMenu.get_children():
		child.modulate.a = 0
		child.position.x = 300
		InterpolateObject(child, "position:x", 0, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)
		InterpolateObject(child, "modulate:a", 1, 0.75, Tween.EASE_OUT, Tween.TRANS_CUBIC)


func NewMenuOut() -> void:

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

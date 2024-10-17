extends Node

@onready var sequence : String = "StartScreen"
@onready var paused : bool = false
@onready var pause_sound: AudioStreamPlayer2D = $pause_sound
@onready var hearts_text: Label = $pause_menu/VBoxContainer/hearts_text
@onready var feathers_text: Label = $pause_menu/VBoxContainer/feathers_text
@onready var pause_menu: CanvasLayer = $pause_menu

# Checkpoints / Respawn positions
@onready var cp_position : Vector2
@onready var temp_cp_position : Vector2
@onready var current_grave: Area2D
@onready var new_grave : Area2D

# Lives
@onready var starting_hearts : int = 3 # 3 starting hearts
@onready var hearts_limit : int = 9 # hard heart limit
@onready var max_hearts : int = starting_hearts
@onready var hearts_at_limit : bool = false
@onready var max_health : int = max_hearts * 2
@onready var health : int = max_health

@onready var death_count : int = 0

# Feathers
@onready var starting_feathers : int = 1
@onready var feathers_limit : int = 5
@onready var max_feathers : int = starting_feathers
@onready var feathers_at_limit : bool = false
@onready var max_jumps : int = max_feathers * 2
@onready var jumps : int = max_jumps
@onready var f_max_jumps : float
@onready var f_jumps : float

# Collectables storage
@onready var collected_items = []
@onready var collected_items_permanent = []

# Music
@onready var main_theme: AudioStreamPlayer2D = $main_theme
@onready var main_theme_pos: float = 0

# Game timer
@onready var time_elapsed = 0.0
@onready var pause_timer = true

# check if main scene has been loaded
@onready var main_started = false

# camera override from player. false = follow player
@onready var override_camera : String = ""

# health and jumps min boundaries
static var min_health : int = 0
static var min_hearts : int = 1
static var min_jumps : int = 0
static var min_feathers : int = 1

func _ready() -> void:
	#start_theme()
	pause_menu.hide()

func _process(delta: float) -> void:
	
	if !pause_timer:
		time_elapsed += delta
	
	# Health boundaries
	if health > max_health:
		health = max_health
	if health < min_health:
		health = 0
	if hearts_at_limit:
		max_hearts = hearts_limit
	max_health = max_hearts * 2
	
	# Jumps boundaries
	if jumps > max_jumps:
		jumps = max_jumps
	if jumps < min_jumps:
		jumps = 0
	if feathers_at_limit:
		max_feathers = feathers_limit
	max_jumps = max_feathers * 2
	
	f_max_jumps = float(max_jumps)
	f_jumps = float(jumps)
	
	main_theme_pos = main_theme.get_playback_position()
	
	hearts_text.text = "Hearts:   " + str(max_hearts) + "/" + str(hearts_limit)
	feathers_text.text = "Feathers: " + str(max_feathers) + "/" + str(feathers_limit)
	
	if Input.is_action_just_pressed("pause") and !paused and main_started:
		paused = true
		pause_sound.play()
		pause_menu.show()
		main_theme.stream_paused = true
		get_tree().paused = true
	elif Input.is_action_just_pressed("pause") and paused and main_started:
		paused = false
		pause_sound.play()
		pause_menu.hide()
		main_theme.stream_paused = false
		get_tree().paused = false

func set_max_health():
	health = max_health

func set_max_jumps():
	jumps = max_jumps

func save_collected(item:String):
	collected_items.append(item)

func clear_collected():
	collected_items.clear()

func save_collected_permanent(item:String):
	collected_items_permanent.append(item)

func start_theme():
	if !main_theme.playing:
		main_theme.play(main_theme_pos)

func stop_theme():
	if main_theme.playing:
		main_theme.pause()

func start_timer():
	pause_timer = false

func stop_timer():
	pause_timer = true

func set_start_position(marker : Marker2D):
	cp_position = marker.position

func set_main_started():
	main_started = true

func hard_reset():
	main_started = false
	time_elapsed = 0
	max_hearts = starting_hearts
	Util.hearts_at_limit = false
	set_max_health()
	max_feathers = starting_feathers
	Util.feathers_at_limit = false
	collected_items.clear()
	collected_items_permanent.clear()
	death_count = 0

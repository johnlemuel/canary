extends CanvasLayer

static var dark = Color(35, 76, 89, 255)
static var dark_mid = Color(87, 158, 148, 255)
static var light_mid = Color(165, 206, 187, 255)
static var light = Color(227, 239, 223, 255)

@onready var label = $Label
@onready var read_timer: Timer = $read_timer
@onready var bgjam_12_splash: Sprite2D = $bgjam12splash
@onready var minutes
@onready var seconds
@onready var milliseconds
@onready var time_string
@onready var time_elapsed

@onready var hold_time : float = 0.0
@onready var skipped : bool = false

var intro_text = "made\nfor GBJam 12\n" \
	+ "with Godot 4\n" \
	+ "by yunglem"
var instructions_text = "W A S D to move & look\n" \
	+ "K to jump"

var plot_text1 = "In 1911, coal miners began using sacrificial canaries to detect deadly gases..." 
var plot_text2 = "The birds, more sensitive to toxins, would show distress or die, warning miners to evacuate before gas levels became lethal..."
var plot_text3 = "Though this practice has now ended, the spirits of canaries from abandoned coal mines still seek their final rest..."
var plot_text4 = "Obtain 5 feathers from other fallen canaries and escape the mines.\n Good luck!"

var plot_texts = [plot_text1, plot_text2, plot_text3, plot_text4]

var respawn_texts = ["don't give up!",
	"just a scratch!", 
	"oh no!",
	"just keep going!", 
	"keep trying!",
	"nice try!", 
	"not done yet!",
	"keep it up!",
	"never back down!", 
	"never give up!"]

var pretime_text = "thanks for playing!\n"\
	+ "you found peace in\n"
var heartcount_text = "\nwith "
var heartcount_text2 = "/"
var heartcount_text3 = " hearts."
var deathcount_text = "\nyou lost your way\n"
var deathcount_text2 = " time(s)"
var restart_text = "\n\nK to try again"
var time_text = ""

func _ready() -> void:
	SceneTransition.set_palette_brightness(-1)
	label.hide()

	if Util.sequence == "StartScreen":
		start_screen()
	elif Util.sequence == "RespawnScreen":
		respawn_screen()
	elif Util.sequence == "FinishScreen":
		finish_screen()

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept") and !skipped:
		hold_time += delta
		if hold_time > 1: # 1 sec hold time
			skipped = true
			await go_to_menu()
	else:
		hold_time = 0.0
	
	if Input.is_action_just_pressed("ui_accept") and (Util.sequence == "StartScreen"):
		if !read_timer.is_stopped():
			read_timer.stop()
			read_timer.emit_signal("timeout")
	elif Input.is_action_just_pressed("ui_accept") and Util.sequence == "FinishScreen":
		await go_to_menu()
		
	if Util.sequence == "StartScreen":
		$skip_text.show()
	else:
		$skip_text.hide()


func start_screen():
	read_timer.wait_time = 0.5
	read_timer.start()
	await read_timer.timeout
	await fade_in_out(bgjam_12_splash, 2.0)
	
	SceneTransition.set_palette_brightness(0)
	
	await fade_in_out(intro_text, 2)
	
	$skip_text.show()
	for text in plot_texts:
		await fade_in_out(text, 8)
	$skip_text.hide()
	
	await fade_in_out(instructions_text, 2)
	
	SceneTransition.change_scene("res://scenes/startmenu.tscn")

func respawn_screen():
	SceneTransition.set_palette_brightness(-1)
	Util.set_max_health()
	Util.clear_collected()
	
	await fade_in_out(respawn_texts.pick_random(), 0.5)
	SceneTransition.change_scene("res://scenes/main.tscn")

func finish_screen():
	time_elapsed = Util.time_elapsed
	minutes = time_elapsed / 60
	seconds = fmod(time_elapsed, 60)
	milliseconds = fmod(time_elapsed, 1) * 100
	time_string = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	time_text = time_string
	var finaltext = pretime_text + time_text \
		+ heartcount_text + str(Util.max_hearts) + heartcount_text2 + str(Util.hearts_limit) + heartcount_text3 \
		+ deathcount_text + str(Util.death_count) + deathcount_text2 \
		+ restart_text
	
	label.text = finaltext
	fade_in(label, 0.05)

func go_to_menu():
	Util.hard_reset()
	$skip_text.hide()
	SceneTransition.change_scene("res://scenes/startmenu.tscn")

func fade_in_out(node, time : float):
	var fade_time = 0.05
	if typeof(node) == 4: # 4 = Type String: https://docs.godotengine.org/en/3.2/classes/class_@globalscope.html#enum-globalscope-variant-type
		label.text = node
		node = label
	read_timer.wait_time = time
	await fade_in(node, fade_time)
	read_timer.start()
	await read_timer.timeout
	await fade_out(node, fade_time)

func fade_in(node, fade_time : float):
	SceneTransition.set_palette_brightness(-1)
	node.show()
	await SceneTransition.fade_in(fade_time)
	
func fade_out(node, fade_time : float):
	await SceneTransition.fade_out(fade_time)
	node.hide()

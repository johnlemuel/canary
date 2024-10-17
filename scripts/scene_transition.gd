extends CanvasLayer

@onready var palette_overlay: ColorRect = $palette_overlay
@onready var timer: Timer = $Timer
@onready var brightness: float = 0.0
@onready var material : ShaderMaterial = palette_overlay.get_material()

@onready var palettes = []
const palette_folder = "res://assets/palettes/"
var current_palette = 0

func _ready() -> void:
	await load_palettes()

func change_scene(target: String):
	var time = 0.05
	await fade_out(time)
	get_tree().change_scene_to_file(target)
	await fade_in(time)

func reload_scene():
	var time = 0.01
	await fade_out(time)
	get_tree().reload_current_scene()
	await fade_in(time)
	
func _process(delta: float) -> void:
	if brightness > 0.0:
		brightness = 0
	
	if Input.is_action_just_pressed("change_palette"):
		await change_palette(palettes[current_palette])
		current_palette += 1
		if current_palette >= palettes.size(): current_palette = 0

func fade_out(time : float):
	timer.wait_time = time
	#set_palette_brightness(0)
	for i in range(0, 10):
		brightness -= 0.1
		palette_overlay.material.set_shader_parameter("brightness", brightness)
		timer.start()
		await timer.timeout
	palette_overlay.material.set_shader_parameter("brightness", -1)
	set_palette_brightness(-1)
	
func fade_in(time : float):
	timer.wait_time = time
	set_palette_brightness(-1)
	for i in range(0, 10):
		if brightness < 0.0:
			brightness += 0.1
		palette_overlay.material.set_shader_parameter("brightness", brightness)
		timer.start()
		await timer.timeout
	palette_overlay.material.set_shader_parameter("brightness", 0)
	set_palette_brightness(0)

func set_palette_brightness(value : float):
	if value < -1: value = -1
	elif value > 0: value = 0
	brightness = value
	palette_overlay.material.set_shader_parameter("brightness", value)
	
func load_palettes():
	for file_name in DirAccess.get_files_at("res://assets/palettes/"):
		if (file_name.get_extension() == "import"):
			file_name = file_name.replace('.import', '')
			palettes.append(ResourceLoader.load("res://assets/palettes/"+file_name))

func change_palette(palette):
	pass
	await fade_out(0.01)
	palette_overlay.material.set_shader_parameter("target_palette", palette)
	await fade_in(0.01)

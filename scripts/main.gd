extends Node

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var start_position: Marker2D = $start_position
@onready var player_light: PointLight2D = $Player/player_light

const light_scale_dark : float = 0.9
const light_scale_bright : float = 5.0

func _ready() -> void:
	if !Util.main_started:
		Util.set_start_position(start_position)
	if Util.health == Util.max_health:
		player.start_position(Util.cp_position)
	else:
		player.start_position(Util.temp_cp_position)
	
	player_light.texture_scale = light_scale_dark

func _process(delta: float) -> void:
	
	#if Input.is_action_just_pressed("test_button"):
		#pass
		#Util.max_hearts += 1
	#if Input.is_action_just_pressed("testbutton2"):
		#pass
		#Util.max_feathers += 1
		
	if player.global_position.y < -320 and player.global_position.x > 2200:
		player_light.texture_scale = lerp(player_light.texture_scale, light_scale_bright, delta)
	else:
		player_light.texture_scale = lerp(player_light.texture_scale, light_scale_dark, delta * 2)

extends Node2D

@onready var player: CharacterBody2D = $"../../Player"
@onready var feathers = $Feathers
@onready var regain: Timer = $regain_feathers
@onready var sound: AudioStreamPlayer2D = $feather_gain_sound

@onready var current_feathers: int = Util.max_feathers
@onready var feather = preload("res://scenes/feather.tscn")
@onready var current_jumps: float = Util.jumps

@onready var jumps_arr := Array([], TYPE_FLOAT, "", null)
@onready var gaining_state : bool = false

@onready var y_pos = 20
@onready var x_pos = 20
@onready var delay_jump_time

func _ready() -> void:
	pass
	for i in range(Util.max_feathers - 1):
		new_feather()
	update_jumps_arr()

func _process(_delta: float) -> void:
	
	if current_feathers != Util.max_feathers and !Util.feathers_at_limit:
		current_feathers = Util.max_feathers
		await gain_feather()
		if Util.max_feathers == Util.feathers_limit:
			Util.feathers_at_limit = true

	
	if current_jumps > Util.jumps and gaining_state == false:
		update_jumps_arr()
	elif current_jumps < Util.jumps and gaining_state == false:
		regain_feathers_anim(0.025, -80)

func _on_delay_jump_timeout() -> void:
	pass
	for child in feathers.get_children():
		jump_feather(child)
		await $bounce.timeout
	
func jump_feather(target):
	pass
	if target.animation != "0":
		target.position.y = y_pos + 1
		$bounce.start()
		await $bounce.timeout
		target.position.y = y_pos

func gain_feather():
	pass
	gaining_state = true
	sound.pitch_scale = 1
	regain.wait_time = 0.075
	
	regain_feathers_anim(0.1, 0)
	
	new_feather()
	if feathers.get_child_count() == Util.max_feathers:
		sound.play()
	regain.start()
	await regain.timeout
	Util.set_max_jumps()
	current_jumps = Util.jumps
	gaining_state = false

func update_jumps_arr():
	jumps_arr.clear()
	for i in range(0, Util.jumps):
		jumps_arr.append(0.5)
	for i in range(Util.jumps, Util.max_jumps):
		jumps_arr.append(0)
	for i in range(0, Util.max_feathers):
		if jumps_arr[i+1]:
			jumps_arr[i] += jumps_arr[i + 1]
			jumps_arr.pop_at(i + 1)
	
	current_jumps = Util.jumps
	update_feathers(jumps_arr)

func update_feathers(values):
	for i in feathers.get_child_count():
		feathers.get_children()[i].play(str(values[i]))
		
func new_feather():
	var new_feather_instance = feather.instantiate()
	feathers.add_child(new_feather_instance)
	if Util.max_jumps - Util.jumps == 0: new_feather_instance.play("1")
	elif Util.max_jumps - Util.jumps == 1: new_feather_instance.play("0.5")
	else: new_feather_instance.play("0")
	new_feather_instance.position.y = y_pos
	new_feather_instance.position.x = x_pos
	x_pos += 12

func regain_feathers_anim(anim_speed, sound_vol):
	regain.wait_time = anim_speed
	sound.pitch_scale = 1
	var pitch_increase = 0.05
	sound.volume_db = sound_vol
	for i in range(0, jumps_arr.size()):
		
		if jumps_arr[i] == 0:
			jumps_arr[i] = 0.5
			update_feathers(jumps_arr)
			regain.start()
			sound.play()
			sound.pitch_scale += pitch_increase
			await regain.timeout
		if jumps_arr[i] == 0.5:
			jumps_arr[i] = 1
			update_feathers(jumps_arr)
			regain.start()
			sound.play()
			sound.pitch_scale += pitch_increase
			await regain.timeout
		
		if i == Util.max_feathers - 1:
			break
	Util.set_max_jumps()
	current_jumps = Util.jumps

extends Node2D

# Note: start position of hearts is x8, y8; x44, y8
# 		add 12 to each subsequent heart

@onready var player: CharacterBody2D = $"../../Player"
@onready var hearts = $Hearts
@onready var regain: Timer = $regain_health
@onready var sound: AudioStreamPlayer2D = $heart_gain_sound

@onready var current_hearts: int = Util.max_hearts
@onready var heart = preload("res://scenes/heart.tscn")
@onready var current_health: float = Util.health

@onready var health_arr := Array([], TYPE_FLOAT, "", null)
@onready var gaining_state : bool = false

@onready var y_pos = 8
@onready var x_pos = 44
@onready var delay_jump_time

func _ready() -> void:
	pass
	for i in range(Util.max_hearts - 3):
		new_heart()
	update_health_arr()

func _process(_delta: float) -> void:
	if current_hearts != Util.max_hearts and !Util.hearts_at_limit:
		current_hearts = Util.max_hearts
		await gain_heart()
		if Util.max_hearts == Util.hearts_limit:
			Util.hearts_at_limit = true
	
	if current_health != Util.health and gaining_state == false:
		update_health_arr()

func _on_delay_jump_timeout() -> void:
	for child in hearts.get_children():
		jump_heart(child)
		await $jump.timeout
	
func jump_heart(target):
	if target.animation != "0":
		target.position.y = y_pos + 1
		$jump.start()
		await $jump.timeout
		target.position.y = y_pos

func gain_heart():
	gaining_state = true
	sound.pitch_scale = 1
	
	for i in range(0, health_arr.size()): #TODO : make this better lol
		
		if health_arr[i] == 0:
			health_arr[i] = 0.5
			update_hearts(health_arr)
			regain.start()
			sound.play()
			sound.pitch_scale += 0.1
			await regain.timeout
		if health_arr[i] == 0.5:
			health_arr[i] = 1
			update_hearts(health_arr)
			regain.start()
			sound.play()
			sound.pitch_scale += 0.1
			await regain.timeout
			
		if i > Util.max_hearts:
			break
	
	new_heart()
	if hearts.get_child_count() == Util.max_hearts:
		sound.play()
	regain.start()
	await regain.timeout
	Util.set_max_health()
	current_health = Util.health
	gaining_state = false

func update_health_arr():
	health_arr.clear()
	for i in range(0, Util.health):
		health_arr.append(0.5)
	for i in range(Util.health, Util.max_health):
		health_arr.append(0)
	for i in range(0, Util.max_hearts):
		if health_arr[i+1]:
			health_arr[i] += health_arr[i + 1]
			health_arr.pop_at(i + 1)
	
	current_health = Util.health
	update_hearts(health_arr)

func update_hearts(values):
	for i in hearts.get_child_count():
		hearts.get_children()[i].play(str(values[i]))
		
func new_heart():
	var new_heart_instance = heart.instantiate()
	hearts.add_child(new_heart_instance)
	new_heart_instance.play("1")
	new_heart_instance.position.y = y_pos
	new_heart_instance.position.x = x_pos
	x_pos += 12

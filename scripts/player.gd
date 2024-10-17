extends CharacterBody2D

@onready var camera: Camera2D = $Camera2D
@onready var sprite = $AnimatedSprite2D
@onready var particles_run: CPUParticles2D = $particles_run
@onready var first_spawn_timer: Timer = $first_spawn_timer
@onready var audio_spawn: AudioStreamPlayer2D = $audio_spawn
@onready var spawn_particles: CPUParticles2D = $spawn_particles
@onready var death_particles: CPUParticles2D = $death_particles
@onready var death_timer: Timer = $death_timer

@onready var particles_jump = preload("res://scenes/particles_jump.tscn")

@onready var dir = -1
@onready var vel_dir = 0.0
@onready var stun : bool
@onready var invincible : bool
@onready var spikes_invincible : bool
@onready var in_grave : bool = false
@onready var spawning_anim : bool = true
@onready var dying : bool = false

const SPEED = 60.0
const JUMP_VELOCITY = -180.0
const jump_buffer = 50
const max_fall_speed = 150
const ouch_y = 124
const ouch_x = int(ouch_y / 2)
const camera_x_offset_amount = 32
const camera_y_offset_amount = 40

func _ready():
	if Util.health == Util.max_health:
		sprite.hide()
		await spawn_anim()
	else:
		sprite.show()
		spawning_anim = false
	
	$spawn_timer.start()
	stun = true
	$invincibility_timer.start()
	invincible = true
	self.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	set_collision_mask_value(9, true)
	

func _physics_process(delta: float) -> void:
	
	if !spawning_anim:
		vel_dir = Input.get_axis("move_left", "move_right")

	# Handle jump.
	var pitch = 0.5 + (1 - (Util.f_jumps / Util.f_max_jumps))
	$sound_jump.pitch_scale = pitch
	if !stun:
		if Input.is_action_just_pressed("jump") and Util.jumps > 0 and !spawning_anim:
			velocity.y = JUMP_VELOCITY
			vel_dir = -dir
			$sound_jump.play()
			Util.jumps -= 1
			var jump_particle_instance = particles_jump.instantiate()
			add_child(jump_particle_instance)
		if velocity.y > max_fall_speed:
			velocity.y = max_fall_speed
	
	if is_on_floor():
		Util.set_max_jumps()
	elif !dying:
			velocity += get_gravity() * delta
	
	if vel_dir != 0 and is_on_floor():
		particles_run.emitting = true
	else:
		particles_run.emitting = false

	if !stun:
		if velocity.x < 0:
			dir = 1
		elif velocity.x > 0:
			dir = -1
		if vel_dir:
			velocity.x = vel_dir * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if $stun_timer.is_stopped() and $spawn_timer.is_stopped():
		stun = false
	if $invincibility_timer.is_stopped() and !spawning_anim:
		invincible = false
		spikes_invincible = false
		$flash_timer.stop()
		if !dying:
			sprite.show()
		
	if $spikes_collider.is_colliding() and spikes_invincible == false:
		hit_spikes()

	if $one_way_collider.is_colliding():
		set_collision_mask_value(9, false)
	else:
		set_collision_mask_value(9, true)
	
	if $ground_left.is_colliding() and $ground_right.is_colliding() and is_on_floor() and !invincible:
		Util.temp_cp_position = global_position

	move_and_slide()
	update_animation()
	
	if velocity.x != 0 and is_on_floor() and $walk_sound_timer.is_stopped(): 
		$sound_walk.play()
		$walk_sound_timer.start()
	
	if Util.override_camera == "":
		camera.global_position = lerp(camera.global_position, self.global_position, delta)
		update_camera(delta)
	
	if in_grave and Input.is_action_just_pressed("claim_grave") and !(Util.cp_position == Util.new_grave.global_position) and Util.new_grave.name != "spawn":
		await activate_checkpoint(Util.new_grave)

func update_animation():
	if dir == 1 : sprite.flip_h=true
	if dir == -1 : sprite.flip_h=false
	
	if velocity.x == 0 and is_on_floor():
		sprite.animation = "idle"
		sprite.stop()
	if velocity.x != 0 and is_on_floor():
		sprite.play("walk")
	if velocity.y < 0:
		sprite.play("jump_squat")
	if velocity.y > jump_buffer and !is_on_floor():
		sprite.play("glide")
	if invincible and $flash_timer.is_stopped():
		$flash_timer.start()

func _on_hazard_collision_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy") and !invincible:
		collide_enemy(area)
		
	if area in $"../Pickups/Checkpoints".get_children():
		Util.new_grave = area
		in_grave = true
		
	if area.is_in_group("override_camera"):
		Util.override_camera = area.get_parent().name


func _on_flash_timer_timeout() -> void:
	if !dying:
		sprite.visible = !sprite.visible

func collide_enemy(area):
	$stun_timer.start()
	$invincibility_timer.start()
	stun = true
	invincible = true
	$sound_hurt.play()
	velocity.y = -ouch_y
	if position.x > area.global_position.x:
		velocity.x = ouch_x
	else:
		velocity.x = -ouch_x
	Util.health -= 1
	if Util.health < 1:
		self.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		velocity = Vector2(0,0)
		respawn()

func set_checkpoint(area):
	Util.cp_position = area.global_position

func respawn():
	dying = true
	Util.stop_timer()
	death_timer.start()
	$stun_timer.start()
	stun = true
	sprite.hide()
	death_particles.emitting = true
	await death_timer.timeout
	stun = true
	Util.death_count += 1
	Util.sequence = "RespawnScreen"
	SceneTransition.change_scene("res://scenes/text_screen.tscn")

func hit_spikes():
	if !dying:
		$stun_timer.start()
		$invincibility_timer.start()
		stun = true
		spikes_invincible = true
		$sound_hurt.play()
		Util.health -= 1
		self.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		velocity = Vector2(0,0)
	
	if Util.health < 1:
		respawn()
	else:
		SceneTransition.reload_scene()
		
func update_camera(delta):
	var x_offset_target : float = camera_x_offset_amount * vel_dir
	camera.offset.x = lerp(camera.offset.x, x_offset_target, delta)
	
	var look_dir = Input.get_axis("look_up", "look_down")
	var y_offset_target : float = (camera_y_offset_amount * look_dir) - 16
	if velocity.y > 149:
		y_offset_target += (velocity.y / 1.5)
	var delta_y = delta
	if look_dir != 0: delta_y *= 2
	camera.offset.y = lerp(camera.offset.y, y_offset_target, delta_y / 1.8)


func _on_entity_item_collision_area_exited(area: Area2D) -> void:
	if area.is_in_group("override_camera"):
		Util.override_camera = ""
	if area in $"../Pickups/Checkpoints".get_children():
		in_grave = false

func start_position(pos : Vector2):
	global_position = pos
	camera.position_smoothing_enabled = false
	camera.global_position = pos
	await $spawn_timer.timeout
	camera.position_smoothing_enabled = true

func activate_checkpoint(grave: Area2D):
	grave.activate()
	Util.current_grave = Util.new_grave
	set_checkpoint(grave)

func spawn_anim():
	spawning_anim = true
	if !Util.main_started:
		first_spawn_timer.wait_time = 3.0
	else:
		first_spawn_timer.wait_time = 1.0
	first_spawn_timer.start()
	await first_spawn_timer.timeout
	audio_spawn.play()
	spawn_particles.emitting = true
	sprite.show()
	velocity.y = JUMP_VELOCITY
	vel_dir = -dir
	
	spawning_anim = false
	Util.set_main_started()
	Util.start_timer()

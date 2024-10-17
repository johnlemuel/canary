extends Area2D
@onready var player: CharacterBody2D = $"../../../Player"
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $"../../../Player/Camera2D"

@onready var max_particle_dis = 250.0
@onready var min_particle_dis = 36.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.frame = int(global_position.x) % 6
	sprite.play()
	
	if self.name in Util.collected_items or self.name in Util.collected_items_permanent:
		queue_free()
	
func _process(delta: float) -> void:
	if Util.override_camera == self.name:
		var target_x = global_position.x - camera.global_position.x
		var target_y = global_position.y - camera.global_position.y - 16
		var target = Vector2(target_x, target_y)
		
		camera.offset = lerp(camera.offset, target, delta*1.5)
	
	if get_parent().name == "Orb":
		play_particles()

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		sound.pitch_scale = randf_range(0.75, 1.25)
		sound.play()
		if get_parent().name != "Orb":
			hide()
		await sound.finished
		$CollisionShape2D.disabled = true
		if get_parent().name == "Big Hearts":
			Util.max_hearts += 1
			Util.save_collected_permanent(self.name)
		elif get_parent().name == "Hearts":
			Util.health += 1
			Util.save_collected(self.name)
		elif get_parent().name == "Feathers":
			Util.max_feathers += 1
			Util.save_collected_permanent(self.name)
		elif get_parent().name == "Orb":
			Util.stop_timer()
			Util.sequence = "FinishScreen"
			stop_particles()
			play_goal_particles()
			SceneTransition.change_scene("res://scenes/text_screen.tscn")
		
		if !get_parent().name == "Orb":
			queue_free()

func play_particles():
	$goal_particles_a.emitting = true
	var player_dis = global_position.distance_to(player.global_position)
	
	if player_dis >= max_particle_dis: player_dis = max_particle_dis
	if player_dis <= min_particle_dis: player_dis = min_particle_dis
	
	var velocity_max = player_dis * 1.5
	var velocity_min = player_dis / 2
	
	var scale_max = player_dis / 75
	var scale_min = scale_max / 2

	$goal_particles_a.initial_velocity_max = int(velocity_max)
	$goal_particles_a.initial_velocity_min = int(velocity_min)
	$goal_particles_a.set_param_max($goal_particles_a.PARAM_SCALE, scale_max)
	$goal_particles_a.set_param_min($goal_particles_a.PARAM_SCALE, scale_min)
	
	
	
	
func stop_particles():
	$goal_particles_a.emitting = false
	
func play_goal_particles():
	pass

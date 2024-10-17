extends Area2D

@onready var camera: Camera2D = $"../../../Player/Camera2D"
@onready var activation_particles: CPUParticles2D = $activation_particles
@onready var settle_particles: CPUParticles2D = $settle_particles
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var point_light: PointLight2D = $PointLight2D
@onready var audio_rise: AudioStreamPlayer2D = $audio_rise
@onready var audio_settle: AudioStreamPlayer2D = $audio_settle
@onready var unclaimed_particles: CPUParticles2D = $unclaimed_particles
@onready var claimed_particles: CPUParticles2D = $claimed_particles

@onready var grave_claimed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.name == "spawn" and !Util.main_started:
		Util.cp_position = self.global_position
		Util.new_grave = self
		Util.current_grave = Util.new_grave
		activate()
	elif !(Util.cp_position == self.global_position):
		reset_grave()
	else:
		claimed_particles.emitting = true
		anim.play("claimed")


func _process(delta: float) -> void:
	if Util.override_camera == self.name:
		var target_x = global_position.x - camera.global_position.x
		var target_y = global_position.y - camera.global_position.y - 16
		var target = Vector2(target_x, target_y)
		
		camera.offset = lerp(camera.offset, target, delta*1.5)

func activate():
	unclaimed_particles.emitting = false
	activation_particles.emitting = true
	anim.play("rise")
	audio_rise.play()
	await anim.animation_finished
	if self.name != "spawn": 
		audio_settle.play()
	settle_particles.emitting = true
	activation_particles.emitting = false
	claimed_particles.emitting = true
	

func reset_grave():
	claimed_particles.emitting = false
	activation_particles.emitting = false
	if self.name != "spawn":
		unclaimed_particles.emitting = true
		claimed_particles.emitting = false
		anim.play("RESET")
	else:
		anim.play("claimed")
		claimed_particles.emitting = true

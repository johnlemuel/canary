extends CPUParticles2D
@onready var timer: Timer = $Timer
@onready var dim : Gradient = load("res://scenes/particle_color_ramp_low_jumps.tres")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = lifetime
	if Util.jumps < 3 and !$"..".is_on_floor():
		color_ramp = dim
	emitting = true
#
#ka
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if emitting == true:
		await timer.timeout
		emitting = false
		queue_free()
	scale_amount_min = 0.5 * timer.wait_time
	scale_amount_max = 2 * timer.wait_time
	

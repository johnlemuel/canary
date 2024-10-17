extends Label

@onready var minutes
@onready var seconds
@onready var milliseconds
@onready var time_string
@onready var time_elapsed

func _process(_delta: float) -> void:
	time_elapsed = Util.time_elapsed
	minutes = time_elapsed / 60
	seconds = fmod(time_elapsed, 60)
	milliseconds = fmod(time_elapsed, 1) * 100
	time_string = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	text = time_string

extends Control

func _ready() -> void:
	$AnimationPlayer.play("float")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		$focus_sound.play()
		await SceneTransition.change_scene("res://scenes/main.tscn")

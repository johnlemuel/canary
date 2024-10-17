extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var player_dir_box = $Sprite2D
@onready var player = get_parent().get_parent().get_parent().get_node("Player")

var speed = 12
var direction = -1
var stacked_speed = speed / randf_range(3, 6)

func _physics_process(delta: float) -> void:
	velocity.x = speed * direction
	if !is_on_floor():
		velocity += get_gravity() * delta

	if $rc_stack.get_collider() in get_parent().get_children():
		speed = stacked_speed
	else: 
		speed = 12
		
		if $wall_detect.is_colliding():
			direction *= -1
			$wall_detect.rotation += PI
		elif !$rc_leftdown.is_colliding():
			direction = 1
			$wall_detect.rotation = 0
		elif !$rc_rightdown.is_colliding():
			direction = -1
			$wall_detect.rotation = PI
	
	move_and_slide()
	self.rotation = 0
	update_animation()
	if is_on_floor() and $sound_walk_timer.is_stopped(): 
		$sound_walk.play()
		$sound_walk_timer.start()
	
var look_buffer = PI/12
# angles based on 12hr clock
var angle02 = -look_buffer		# top right bot
var angle01 = -PI/2+look_buffer	# top right top
var angle10 = -PI+look_buffer	# top left bot
var angle11 = -PI/2-look_buffer	# top left top
var angle06 = PI/2
var angle12 = -PI/2

func update_animation():
	# get angle to player
	player_dir_box.look_at(Vector2(player.position.x, player.position.y))
	var angle_to_player = player_dir_box.rotation

	# 'clamp' angle to PI max
	if angle_to_player > PI:
		player_dir_box.rotation -= PI
	if angle_to_player < -PI:
		player_dir_box.rotation += PI
	
	# handle horizontal flip
	if angle_to_player < angle01 or angle_to_player > angle06:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	
	# handle diagonal and up animation
	if (angle_to_player < angle02 and angle_to_player > angle01)\
	or (angle_to_player > angle10 and angle_to_player < angle11):
		sprite.play("diag")
	elif angle_to_player < angle01 and angle_to_player > angle11:
		sprite.play("up")
	else:
		sprite.play("mid")

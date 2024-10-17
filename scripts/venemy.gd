extends RigidBody2D

@onready var sprite = $AnimatedSprite2D
@onready var player = get_parent().get_parent().get_parent().get_node("Player")
@onready var player_dir_box = $Sprite2D
@onready var start = position.x

static var speed = 15

var direction = 1
var movement = Vector2(0,0)


func _physics_process(delta: float) -> void:
	
	if $wall_detect.is_colliding():
		direction *= -1
		$wall_detect.rotation += PI
		$sound_bump.play()
	
	movement.y = speed * delta * direction
	position.x = start
	
	move_and_collide(movement)
	self.rotation = 0
	update_animation()

var look_buffer = PI/12
# angles based on 12hr clock
var angle02 = -look_buffer		# top right bot
var angle01 = -PI/2+look_buffer	# top right top
var angle10 = -PI+look_buffer	# top left bot
var angle11 = -PI/2-look_buffer	# top left top
var angle04 = look_buffer		# bot right top
var angle05 = PI/2-look_buffer	# bot right bot
var angle08 = PI-look_buffer		# bot left top
var angle07 = PI/2+look_buffer	# bot left bot

func update_animation():
	# get angle to player
	player_dir_box.look_at(Vector2(player.position.x, player.position.y))
	var angle_to_player = player_dir_box.rotation

	# 'clamp' angle to PI max
	if angle_to_player > PI:
		player_dir_box.rotation -= PI
	if angle_to_player < -PI:
		player_dir_box.rotation += PI
	
	# handle horizontal animation
	if angle_to_player < angle11 or angle_to_player > angle05:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	# handle diagonal animation
	if (angle_to_player < angle02 and angle_to_player > angle01)\
	or (angle_to_player > angle10 and angle_to_player < angle11):
		sprite.play("up")
		sprite.rotation = 0
		
	elif (angle_to_player > angle04 and angle_to_player < angle05)\
	or (angle_to_player < angle08 and angle_to_player > angle07):
		sprite.play("down")
		sprite.rotation = 0
	else:
		# handle vertical animation
		sprite.play("middle")
		if angle_to_player < angle01 and angle_to_player > angle11:
			sprite.rotation = -PI/2
		elif angle_to_player > angle05 and angle_to_player < angle07:
			sprite.rotation = -PI/2
		else:
			sprite.rotation = 0

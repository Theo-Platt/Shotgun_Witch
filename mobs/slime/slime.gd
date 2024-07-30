extends CharacterBody2D

######################
# Exported Variables #
######################
@export var player = CharacterBody2D
@export var action_frequency = 1000
@export var gravity = 9.8
var id = -1


####################
# Global Variables #
####################
enum {S_DEFAULT, S_JUMP, S_FALL_1, S_FALL_2, S_LAND, S_DIE} # enum: enumerator for the states a slime mob can be in
var state                                                   # enum: contains the current state of the mob
var jump_height                                             # int: the height of the jump
var jump_distance                                           # float: the distance of the jump
var action_timer                                            # float: timeout until next action (jump)
var mirror_sprite                                           # bool:   keeps track of sprite direction



###########
# Signals #
###########
#none :D


###################
# Signal Handlers #
###################
# when any animation finishes, do something
func _on_animated_sprite_2d_animation_finished():
	if state == S_JUMP: 
		state = S_FALL_1
	if state == S_LAND:
		velocity.x = 0
		state = S_DEFAULT
	if state == S_DIE:
		print("slime involuntarily-terminating")
		self.queue_free()

# destroy slime object when it hits the player (player sprite will represent this)
func _on_player_hit():
	print("slime self-terminating")
	self.queue_free()

# if shot, die. TODO this REALLY aught to be done using a collision box. it didnt work originally, but go figure it out. Idea: player has an always on box, slime keeps a variable boolean 'in_range' that sets true when within the box and false when leaving. then just die if in_range.
func _ive_been_shot(player):
	var player_facing_right = player.mirror_sprite
	print("px:"+str(player.position.x)+" right?:"+str(player_facing_right)+" p_range:"+str(player.range))
	
	#is the player facing the slime?
	if (player.position.x < position.x && player_facing_right) || (player.position.x > position.x && !player_facing_right):
		#is the player at (roughly) the same height as the slime?
		if player.position.y - player.spread < position.y && player.position.y + player.spread > position.y: #above slime
			
			#is the player in range of the smime?
			var slime_distance = position.x - player.position.x
			print("sx:"+str(position.x)+" sd:"+str(slime_distance))
			if player_facing_right && slime_distance < player.range:
				state=S_DIE
			elif !player_facing_right && slime_distance > -player.range:
				state=S_DIE

#####################
# Utility Functions #
#####################
# plays the animation passed as a parameter, second parameter unlocks the mirror_sprite var from changing
func play_animation(animation, do_mirror_flip = true):
	if do_mirror_flip: mirror_sprite = position.x < player.position.x
	$AnimatedSprite2D.flip_h = mirror_sprite
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	play_animation("default")
	action_timer = randi() % action_frequency
	state = S_FALL_2
	jump_distance=1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if action_timer > action_frequency:
		action_timer = 0
		play_animation("default")
		if is_on_floor(): state = S_JUMP
		else: state = S_FALL_2
	
	if state == S_DEFAULT:                       
		action_timer += 1 * delta
		play_animation("default")
	
	elif state == S_JUMP:                        play_animation("jump", false)
	elif state == S_FALL_1 || state == S_FALL_2: fall(delta)
	elif state == S_LAND:                        play_animation("land", false)
	elif state == S_DIE:                         die()
	
	move_and_slide()


###################
# Slime Functions #
###################
# determines the length of a jump, initiates the jump, and handles gravity.
func fall(delta):
	play_animation("fall", false)
	if is_on_floor() && state == S_FALL_1:
		var hops = [100,100,150,150,200,200,250,250,300,400,500]
		jump_height = hops[randi() % hops.size()]
		jump_distance = jump_height / 2
		velocity.x =  jump_distance
		velocity.y -= jump_height
		if !mirror_sprite: velocity.x *= -1
		state = S_FALL_2
	elif is_on_floor() && state == S_FALL_2:
		velocity.x /= 50
		state = S_LAND
	else:
		var dx = (jump_distance/40)*delta
		if velocity.x < 0: dx*=-1
		velocity.x += dx
		velocity.y += gravity

#plays the death animation then removes this Mob.
func die():
	play_animation("die")
	pass










extends CharacterBody2D

###########
# Signals #
###########
signal score_increase

######################
# Exported Variables #
######################
@export var player = CharacterBody2D
@export var action_frequency = 1000
@export var gravity = 11


####################
# Global Variables #
####################
enum {S_DEFAULT, S_JUMP, S_FALL_1, S_FALL_2, S_LAND, S_DIE} # enum: enumerator for the states a slime mob can be in
var state                                                   # enum: contains the current state of the mob
var jump_height                                             # int: the height of the jump
var jump_distance                                           # float: the distance of the jump
var action_timer                                            # float: timeout until next action (jump)
var mirror_sprite                                           # bool:   keeps track of sprite direction


###################
# Signal Handlers #
###################
# Handle animation finishing
func _on_animated_sprite_2d_animation_finished():
	if state == S_JUMP: 
		state = S_FALL_1
	if state == S_LAND:
		velocity.x = 0
		state = S_DEFAULT
	if state == S_DIE:
		score_increase.emit()
		print("slime involuntarily-terminating")
		queue_free()


#####################
# Utility Functions #
#####################
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

# plays the animation passed as a parameter, second parameter unlocks the mirror_sprite var from changing
func play_animation(animation, do_mirror_flip = true):
	if do_mirror_flip: mirror_sprite = position.x < player.position.x
	$AnimatedSprite2D.flip_h = mirror_sprite
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.play()

###################
# Slime Functions #
###################
# determines the length of a jump, initiates the jump, and handles gravity.
func fall(delta):
	play_animation("fall", false)
	if is_on_floor() && state == S_FALL_1:
		var hops = [50,100,100,100,150,150,200,200,250,250,300,400]
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
		var dx = (jump_distance/25) * delta 
		if velocity.x < 0: dx*=-1
		velocity.x += dx
		velocity.y += gravity

#plays the death animation then removes this Mob.
func die():
	play_animation("die")


func _on_hurtbox_area_entered(_area):
	$"Hitbox/CollisionShape2D".set_deferred("disabled", true)
	$"World Collision".set_deferred("disabled", true)
	state=S_DIE

func _on_hitbox_area_entered(_area):
	queue_free()

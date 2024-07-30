extends CharacterBody2D

######################
# Public Variables #
######################
@export var speed = 100
@export var health = 3
@export var gravity = 9.8
@export var jump_height_min = 130
@export var jump_height_max = 160
@export var range = 60
@export var spread = 15
@export var ammo_count = 3


#####################
# Private Variables #
#####################
var screen_size                        # huh...: size of the screen
var speed_multiplier                   # float:  modifier on the x-direction speed
var can_move                           # bool:   defines whether the player is allowed to perform inputs
var mirror_sprite                      # bool:   keeps track of sprite direction
var grounded                           # bool:   on ground or not on ground
enum {J_GROUND, J_PREP, J_AIR, J_FALL} # enum:   Jump enumerator for different states of jumping
var jump_primer                        # enum:   keeps track of the current Jump enum value
enum {D_NONE, D_SLIME_HEAD, D_SLIME_BODY}
var death_state
var mutex_because_im_mad_at_this_FUCKING_RACE_CONDITION
var reloading


###########
# Signals #
###########
signal hit(health)  # tell Mob that they hit the player
signal fire# tell Mob that it has been SHOT
signal update_ammo


###################
# Signal Handlers #
###################
# when any animation finishes, do something
func _on_animated_sprite_2d_animation_finished():
	if health <= 0: 
		if   death_state == D_SLIME_BODY: play_animation("death-slime_body")
		elif death_state == D_SLIME_HEAD: play_animation("death-slime_head")
	else:
		can_move = true
		if jump_primer == J_PREP: jump_primer = J_AIR
		$"head/CollisionShape2D".disabled = false
		$"body/CollisionShape2D".disabled = false
		if !mutex_because_im_mad_at_this_FUCKING_RACE_CONDITION:
			if ammo_count > 0:
				ammo_count-=1
			mutex_because_im_mad_at_this_FUCKING_RACE_CONDITION=true
		update_ammo.emit()
		if reloading: 
			reloading = false
			ammo_count+=1
		if ammo_count < 0: ammo_count = 0
		update_ammo.emit()

# handle collisions with the head
func _on_head_collision_body_entered(body):
	if mutex_because_im_mad_at_this_FUCKING_RACE_CONDITION:
		mutex_because_im_mad_at_this_FUCKING_RACE_CONDITION=false
		health = health - 1;
		can_move=false
		
		$"head/CollisionShape2D".set_deferred("disabled", true)
		$"body/CollisionShape2D".set_deferred("disabled", true)
		hit.emit(health)
		if health > 0: 
			play_animation("slime_head_damage")
		else:
			play_animation("slime_head_kill")
			death_state = D_SLIME_HEAD

# handle collisions with the body
func _on_body_collision_body_entered(body):
	if mutex_because_im_mad_at_this_FUCKING_RACE_CONDITION:
		mutex_because_im_mad_at_this_FUCKING_RACE_CONDITION=false
		health = health - 1;
		can_move=false
		$"head/CollisionShape2D".set_deferred("disabled", true)
		$"body/CollisionShape2D".set_deferred("disabled", true)
		hit.emit(health)
		if health > 0: 
			play_animation("slime_body_damage")
		else:
			play_animation("slime_body_kill")
			death_state = D_SLIME_BODY


#####################
# Utility Functions #
#####################
# Called when the node enters the scene tree for the first time.
func _ready():
	start(0,0)
	can_move = false
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	##################
	# Weapon Handler #
	##################
	if Input.is_action_just_pressed("shoot") && is_on_floor() && can_move: 
		shoot_pressed()
	
	if Input.is_action_just_pressed("reload")&& is_on_floor() && can_move:
		if ammo_count < 3:
			print("reloading")
			reload()
	
	
	################
	# Jump Handler #
	################
	
	# Player is on the ground
	if is_on_floor():  
		# if on the ground but not grounded, the ground was just touched this frame. Play landing animation
		if !grounded:
			land()
		
		# jump if possible
		if Input.is_action_just_pressed("jump") && can_move: 
			trigger_jump()
		
		# set grounded
		grounded = true
	
	# Player is not on the ground
	else:
		grounded = false
		velocity.y += gravity
		play_animation("falling")
	
	# the jump windup animation is done, trigger the actual jump
	if jump_primer == J_AIR: jump()
	
	
	###################
	# x-input Handler #
	###################
	
	velocity.x = 0
	if Input.is_action_pressed("move_right") && can_move:
		mirror_sprite = true
		velocity.x += 1
	if Input.is_action_pressed("move_left") && can_move:
		mirror_sprite = false
		velocity.x -= 1
	
	if velocity.length() > 0:
		if is_on_floor() && can_move: play_animation("walk")
	else:
		if is_on_floor() && can_move: play_animation("stand")
	velocity.x *= speed * speed_multiplier
	
	#####################
	# movement & camera #
	#####################
	
	move_and_slide()
	position = position.clamp(Vector2.ZERO, screen_size)

# plays the animation passed as a parameter
func play_animation(animation):
	#print(animation)
	$AnimatedSprite2D.flip_h = mirror_sprite
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.play()

# sets all vars to defaults and position to x,y
func start(x,y):
	position.x = x
	position.y = y
	screen_size = get_viewport_rect().size
	can_move = false
	mirror_sprite = false
	jump_primer = J_GROUND
	speed_multiplier = 1.0
	grounded = true
	death_state = D_NONE
	reloading=false
	ammo_count = 3
	health = 3
	show()

##################
# Jump Functions #
##################
# prime the jump when the jump button was pressed
func trigger_jump():
	jump_primer = J_PREP
	can_move = false
	play_animation("jump")

#perform the actual jump
func jump():
	# Far jump
	if Input.is_action_pressed("jump"):
		velocity.y = -jump_height_max
		speed_multiplier = 1.1
	# Short jump
	else: 
		velocity.y = -jump_height_min
		speed_multiplier = .75
	jump_primer = J_GROUND

# handle hitting the ground after experiencing "gravity"
func land():
	can_move = false
	if speed_multiplier > 0.80: # TODO ha ha, its based on your speed multiplier not the distance you fell. Yes I am mean. yes I will change this once the game has actual drops.
		play_animation("faceplant")
	else:
		play_animation("landing")
	speed_multiplier = 1.0

#####################
# Shotgun Functions #
#####################
# play the shoot animation and emit the fire signal
func shoot_pressed():
	can_move = false
	if ammo_count > 0:
		ammo_count -= 1
		fire.emit()
		play_animation("fire")
		
	else:
		play_animation("no ammo")

func reload():
	can_move =false
	reloading=true
	play_animation("reload")

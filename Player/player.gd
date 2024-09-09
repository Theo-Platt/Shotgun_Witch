extends CharacterBody2D

######################
# Public Variables #
######################
@export var speed = 100
@export var health = 3
@export var gravity = 9.8
@export var jump_height_min = 130
@export var jump_height_max = 160





#####################
# Private Variables #
#####################
var speed_multiplier                   # float:  modifier on the x-direction speed
var mirror_sprite                      # bool:   keeps track of sprite direction
enum {D_NONE, D_SLIME_HEAD, D_SLIME_BODY}
var damage_type
var ammo
var ammo_cap
var fall_distance

enum {S_STAND, S_WALK, S_JUMP, S_AIRBORNE, S_LAND, S_SHOOT, S_RELOAD, S_DAMAGED, S_DYING, S_DEAD, S_PAUSED}
var state
var slime_body_anims = {
	S_DAMAGED : "slime_body_damage",
	S_DYING   : "slime_body_dying",
	S_DEAD    : "slime_body_dead",
}
var slime_head_anims = {
	S_DAMAGED : "slime_head_damage",
	S_DYING   : "slime_head_dying",
	S_DEAD    : "slime_head_dead",
}



###########
# Signals #
###########
signal hit(health)
signal shoot(dir) # Fire gun in dir direction
signal reload


###################
# Signal Handlers #
###################
# when any animation finishes, do something
func _on_animated_sprite_2d_animation_finished():
	if state == S_DYING:
		state = S_DEAD
		speed_multiplier = 0
		if damage_type == D_SLIME_BODY:   play_animation("slime_body_dead")
		elif damage_type == D_SLIME_HEAD: play_animation("slime_head_dead")
	else:
		$head.monitoring = true
		$body.monitoring = true
		damage_type = D_NONE
		speed_multiplier = 1
	
	if state == S_JUMP: 
		jump()
	
	if state == S_LAND || state == S_SHOOT || state == S_RELOAD: 
		fall_distance = 0
		state = S_STAND
	
	if state == S_DAMAGED:
		state = S_STAND
		if ammo!=0: ammo-=1
		#shoot.emit(mirror_sprite)
	
	

# handle collisions with the head
func _on_head_area_entered(body):
	print("Hit")
	if damage_type == D_NONE:
		damage_type = D_SLIME_HEAD
		#body.queue_free()
		print("...in the head")
		health = health - 1;
		$head.set_deferred("monitoring",false)
		$body.set_deferred("monitoring",false)
		hit.emit(health)
		
		if health > 0: 
			print("head damaged")
			play_animation("slime_head_damaged")
			state = S_DAMAGED
		else:
			play_animation("slime_head_dying")
			state = S_DYING
		speed_multiplier = 0.0

# handle collisions with the body
func _on_body_area_entered(body):
	print("Hit")
	if damage_type == D_NONE:
		damage_type = D_SLIME_BODY
		#body.queue_free()
		print("...in the body")
		health = health - 1;
		$head.set_deferred("monitoring",false)
		$body.set_deferred("monitoring",false)
		hit.emit(health)
		if health > 0: 
			print("body damaged")
			play_animation("slime_body_damaged")
			state = S_DAMAGED
		else:
			play_animation("slime_body_dying")
			state = S_DYING
		speed_multiplier = 0.0


#####################
# Utility Functions #
#####################
# Called when the node enters the scene tree for the first time.
func _ready():
	start(0,0)
	state = S_PAUSED
	hide()

func start(x,y):
	position.x = x
	position.y = y
	mirror_sprite = false
	speed_multiplier = 1.0
	health = 3
	state = S_AIRBORNE
	ammo = 3
	ammo_cap = 3
	damage_type = D_NONE
	fall_distance = 0
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if Input.is_action_just_pressed("debug"): 
	if state == S_PAUSED: pass
	else:
		velocity.x = 0
		if Input.is_action_pressed("move_right"):  set_movement(1)
		elif Input.is_action_pressed("move_left"):   set_movement(-1)
		
		if !is_on_floor(): 
			state = S_AIRBORNE
			if fall_distance < velocity.y: fall_distance=velocity.y
		
		if state == S_STAND || state == S_WALK:
			if Input.is_action_just_pressed("shoot"):  
				state = S_SHOOT
				speed_multiplier = .2
				if ammo > 0:
					ammo -= 1
					shoot.emit(mirror_sprite)
					play_animation("fire")
				else:
					play_animation("no ammo")
			elif Input.is_action_just_pressed("reload"): 
				if ammo < ammo_cap:
					state = S_RELOAD
					speed_multiplier = .4
					ammo += 1
					reload.emit()
					play_animation("reload")
			elif Input.is_action_just_pressed("jump"):
				state = S_JUMP
				speed_multiplier = .2
				play_animation("jump")
				
			
			
			if state == S_STAND:  play_animation("stand")
			elif state == S_WALK: play_animation("walk")

		elif state == S_AIRBORNE:
			if is_on_floor(): 
				state = S_LAND
			else:
				velocity.y += gravity
				play_animation("falling")
		
		elif state == S_RELOAD: 
			pass
		
		elif state == S_SHOOT: 
			pass
		
		elif state == S_LAND:
			if fall_distance > 150:
				speed_multiplier = 0.0
				play_animation("faceplant")
			elif fall_distance > 100:
				speed_multiplier = 0.4
				play_animation("landing")
			else:
				speed_multiplier = 0.6
				play_animation("reload") #just because its short.
		
		elif state == S_JUMP:
			pass
		
		elif state == S_DAMAGED || state == S_DYING:
			pass
			# just wait for animations to end.
			# State transition triggered in func _on_animated_sprite_2d_animation_finished()

		elif state == S_DEAD:
			pass
			# You have died.
			# There is nothing left for you but eternity.
	
	
		
		velocity.x *= speed * speed_multiplier
		#print("delta: ",delta)
		velocity *= delta * 1/0.03334
		move_and_slide()

func set_movement(movement):
	velocity.x += movement
	if movement > 0: 
		mirror_sprite = true
	else: 
		mirror_sprite = false

func jump():
	# Far jump
	if Input.is_action_pressed("jump"):
		velocity.y = -jump_height_max
		speed_multiplier = 1.1
	else: # Short jump
		velocity.y = -jump_height_min
		speed_multiplier = .75

func play_animation(animation):
	$AnimatedSprite2D.flip_h = mirror_sprite
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.play()





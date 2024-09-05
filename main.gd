extends Node

@export var slime_scene: PackedScene
@export var shade_scene: PackedScene

#shooting stuff
@export var projectile_scene: PackedScene
@export var projectile_count = 8
@export var projectile_spread = PI/60
@export var projectile_speed = 200

signal player_hit
signal p_health(health)
signal p_ammo(ammo)
signal message(message)

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.max_fps = 30
	$Player.update_ammo.connect(self.sig_ammo_update)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_fire(facing_left):
	spawn_projectiles(facing_left)

func sig_ammo_update():
	$HUD.update_ammo($Player.ammo_count)

func _on_mob_timer_timeout():
	##########
	## Shade #
	##########
	#var shade = shade_scene.instantiate()
	#var spawn = $"spawnpoints/shade_spawns/shade_path"
	#spawn.progress_ratio = randf()
	#var direction = PI
	#shade.position = spawn.position
	#var velocity = Vector2(randf_range(40.0, 75.0), 0.0)
	#shade.linear_velocity = velocity.rotated(direction)
	#add_child(shade)
	
	
	
	#########
	# Slime #
	#########
	print("spawning slime!")
	if $HUD.score > 50:  $"mob timer".wait_time = 1.5
	if $HUD.score > 100: $"mob timer".wait_time = 1.0
	if $HUD.score > 150: $"mob timer".wait_time = .75
	var mob = slime_scene.instantiate()
	
	mob.player = $Player
	mob.score_increase.connect(self.score_increase)
	#_on_player_hit
	var mob_spawn_location
	var spawnpoints = [$"spawnpoints/1",$"spawnpoints/2",$"spawnpoints/3",$"spawnpoints/4",$"spawnpoints/5",$"spawnpoints/6",$"spawnpoints/7",$"spawnpoints/8",$"spawnpoints/9",$"spawnpoints/10",$"spawnpoints/11",$"spawnpoints/12",]
	mob_spawn_location = spawnpoints[randi() % spawnpoints.size()]
	mob.global_position.x = mob_spawn_location.position.x
	mob.global_position.y = mob_spawn_location.position.y
	mob.action_frequency = randi()%1+1
	add_child(mob)

func _on_player_hit(health):
	player_hit.emit()
	$HUD.update_health(health)
	get_tree().call_group("slime", "queue_free")
	if health == 0:
		gameover()

func _on_hud_start_game():
	$"mob timer".start()
	$HUD.score = 0
	$Player.start($"spawnpoints/Player_spawnpoint".position.x,$"spawnpoints/Player_spawnpoint".position.y)

func gameover():
	$"mob timer".stop()
	get_tree().call_group("slime", "queue_free")
	$HUD.game_over()

func score_increase():
	$HUD.score += 5
	$HUD.update_score($HUD.score)

func spawn_projectiles(facing_left):
	for i in projectile_count:
		var projectile = projectile_scene.instantiate()
		projectile.speed = projectile_speed
		if !facing_left: projectile.rotation = PI
		else: projectile.rotation = 0
		projectile.rotation += randf_range(-projectile_spread, projectile_spread)
		projectile.position.x = $Player.position.x
		projectile.position.y = $Player.position.y + 4
		add_child(projectile)

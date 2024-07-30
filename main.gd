extends Node

@export var slime_scene: PackedScene
signal player_hit
signal kill_slime
signal p_health(health)
signal p_ammo(ammo)
signal message(message)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.update_ammo.connect(self.sig_ammo_update)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_fire():
	kill_slime.emit($Player)

func sig_ammo_update():
	$HUD.update_ammo($Player.ammo_count)

func _on_mob_timer_timeout():
	print("spawning slime!")
	var mob = slime_scene.instantiate()
	
	mob.player = $Player
	self.kill_slime.connect(mob._ive_been_shot)
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
	$Player.start($"spawnpoints/Player_spawnpoint".position.x,$"spawnpoints/Player_spawnpoint".position.y)

func gameover():
	$"mob timer".stop()
	get_tree().call_group("slime", "queue_free")
	$HUD.game_over()

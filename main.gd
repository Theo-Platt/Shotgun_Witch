extends Node

@export var slime_scene: PackedScene
signal player_hit
signal kill_slime
signal p_health
signal p_ammo

# Called when the node enters the scene tree for the first time.
func _ready():
	$"mob timer".start()
	self.p_health.connect($HUD.Health_Tracker())
	self.p_ammo.connect($HUD.Ammo_Tracker())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_fire():
	if $Player.ammo_count > 0:
		kill_slime.emit($Player)

func _on_mob_timer_timeout():
	print("spawning slime!")
	var mob = slime_scene.instantiate()
	
	mob.player = $Player
	self.player_hit.connect(mob._on_player_hit)
	self.kill_slime.connect(mob._ive_been_shot)
	#_on_player_hit
	var mob_spawn_location
	var spawnpoint = randi()%12 
	var spawnpoints = [$"spawnpoints/1",$"spawnpoints/2",$"spawnpoints/3",$"spawnpoints/4",$"spawnpoints/5",$"spawnpoints/6",$"spawnpoints/7",$"spawnpoints/8",$"spawnpoints/9",$"spawnpoints/10",$"spawnpoints/11",$"spawnpoints/12",]
	mob_spawn_location = spawnpoints[randi() % spawnpoints.size()]
	mob.global_position.x = mob_spawn_location.position.x
	mob.global_position.y = mob_spawn_location.position.y
	mob.action_frequency = randi()%1+1
	add_child(mob)

func _on_player_hit():
	player_hit.emit()

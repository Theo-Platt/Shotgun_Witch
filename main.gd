extends Node

@export var slime_scene: PackedScene
signal player_hit
signal kill_slime


# Called when the node enters the scene tree for the first time.
func _ready():
	$"mob timer".start()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_fire(direction):
	if direction: print("Fire right!")
	else: print("Fire left!")
	kill_slime.emit($Player.position.x, direction)
	pass # Replace with function body.
	
func _on_mob_timer_timeout():
	print("spawning slime!")
	var mob = slime_scene.instantiate()
	
	mob.player = $Player
	self.player_hit.connect(mob._on_player_hit)
	self.kill_slime.connect(mob._ive_been_shot)
	#_on_player_hit
	var mob_spawn_location
	var spawnpoint = randi()%12 
	var spawnpoints = [$"spawnpoints/spawnpoint_1",$"spawnpoints/spawnpoint_2",$"spawnpoints/spawnpoint_3",$"spawnpoints/spawnpoint_4",$"spawnpoints/spawnpoint_5",$"spawnpoints/spawnpoint_6",$"spawnpoints/spawnpoint_7",$"spawnpoints/spawnpoint_8",$"spawnpoints/spawnpoint_9",$"spawnpoints/spawnpoint_10",$"spawnpoints/spawnpoint_11",$"spawnpoints/spawnpoint_12",]
	mob_spawn_location = spawnpoints[randi() % spawnpoints.size()]
	mob.global_position.x = mob_spawn_location.position.x
	mob.global_position.y = mob_spawn_location.position.y
	mob.action_frequency = randi()%15+5
	add_child(mob)


func _on_player_hit():
	player_hit.emit()

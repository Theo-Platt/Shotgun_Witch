extends Node

#Mobs
@export var slime_scene: PackedScene
@export var shade_scene: PackedScene

var local_score
var player_ref
signal score_increase

var slime_spawn_spot

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func score_increase_middleman():
	score_increase.emit()

func start(player):
	print("Starting Mob Timer")
	$"mob timer".start()
	player_ref = player
	local_score = 0
	
func stop():
	print("Stopping Mob Timer")
	$"mob timer".stop()

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
	#print("spawning slime!")
	if local_score > 50:  $"mob timer".wait_time = 1.5
	if local_score > 100: $"mob timer".wait_time = 1.0
	if local_score > 150: $"mob timer".wait_time = .75
	
	
	slime_spawn_spot = $Path2D/PathFollow2D
	if ! $Path2D/PathFollow2D/onscreen.is_on_screen():
		var mob = slime_scene.instantiate()
		mob.player = player_ref
		mob.score_increase.connect(self.score_increase_middleman)
		mob.position.x = slime_spawn_spot.position.x
		mob.position.y = slime_spawn_spot.position.y
		mob.action_frequency = randi()%1+1
		add_child(mob)
	
	slime_spawn_spot.progress_ratio = randf()


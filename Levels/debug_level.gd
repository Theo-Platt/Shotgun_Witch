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
func _process(_delta):
	pass

func score_increase_middleman():
	print("score_increase_middleman")
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
	#########
	# Slime #
	#########
	#print("spawning slime!")
	if local_score < 50:    $"mob timer".wait_time = 3
	elif local_score < 100: $"mob timer".wait_time = 2.8
	elif local_score < 150: $"mob timer".wait_time = 2.4
	elif local_score < 200: $"mob timer".wait_time = 1.8
	$"mob timer".start()
	
	slime_spawn_spot = $SpawnPath/PathFollow2D
	if ! $SpawnPath/PathFollow2D/onscreen.is_on_screen():
		var mob = slime_scene.instantiate()
		mob.player = player_ref
		mob.score_increase.connect(self.score_increase_middleman)
		mob.position.x = slime_spawn_spot.position.x
		mob.position.y = slime_spawn_spot.position.y
		mob.action_frequency = randi()%1+1
		add_child(mob)
	
	slime_spawn_spot.progress_ratio = randf()


extends Node

#Level
var level_instance
var level


#Godot Functions
func _ready():
	Engine.max_fps = 30

func _process(delta):
	pass

### Player ###
func _on_player_reload():
	$HUD.update_ammo($Player.ammo)

func _on_player_shoot(dir):
	$Gun.spawn_projectiles(dir, $Player.position.x, $Player.position.y)
	$HUD.update_ammo($Player.ammo)

### HUD ###
func _on_player_hit(health):
	#player_hit.emit()
	$HUD.update_health(health)
	#get_tree().call_group("slime", "queue_free")
	if health == 0:
		gameover()

func _on_hud_start_game():
	load_level("debug_level")
	level = $"Level Container".get_child(0)
	level.start($Player)
	$HUD.score = 0
	$Player.start(-300,200)
	
	print("start game")

func gameover():
	level = $"Level Container".get_child(0)
	level.stop()
	get_tree().call_group("slime", "queue_free")
	$HUD.game_over()

func score_increase():
	$HUD.score += 5
	$HUD.update_score($HUD.score)
	level.local_score = $HUD.score



### Levels ###
func unload_level():
	if is_instance_valid(level_instance):
		level_instance.queue_free()
	level_instance = null

func load_level(level_name : String):
	unload_level()
	var level_path := "res://Levels/%s.tscn" % level_name
	var level_resource := load(level_path)
	if level_resource:
		level_instance = level_resource.instantiate()
		$"Level Container".add_child(level_instance)
		level = $"Level Container".get_child(0)
		level.score_increase.connect(self.score_increase)





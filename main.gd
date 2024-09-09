extends Node

#Level
var level_instance
var level


### Godot Functions ###
func _ready():
	Engine.max_fps = 30

func _process(_delta):
	pass



### Player ###
func _on_player_reload():
	$HUD.update_ammo($Player.ammo)

func _on_player_shoot(dir):
	$Gun.spawn_projectiles(dir, $Player.position.x, $Player.position.y)
	$HUD.update_ammo($Player.ammo)

func _on_player_hit(health):
	$HUD.update_health(health)
	if health == 0:
		gameover()



### HUD Scoring ###
func score_increase():
	$HUD.score += 5
	$HUD.update_score($HUD.score)
	level.local_score = $HUD.score



### Start/End Game ###
func _on_hud_start_game():
	$Player.hide()
	load_level("debug_level")
	await get_tree().create_timer(0.5).timeout
	level = $"Level Container".get_child(0)
	level.start($Player)
	level.score_increase.connect(self.score_increase)
	$HUD.score = 0
	$Player.start(-300,200)
	$HUD.update_ammo($Player.ammo)
	$HUD.update_score($HUD.score)
	print("start game")

func gameover():
	level = $"Level Container".get_child(0)
	level.stop()
	get_tree().call_group("slime", "queue_free")
	$HUD.game_over()



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





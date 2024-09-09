extends Node

#Shotgun
@export var projectile_scene: PackedScene
@export var projectile_count = 8
@export var projectile_spread = PI/60 # 0 to PI (0 is no spread, PI is 360 degree spread)
@export var projectile_speed = 200
@export var ammo_capacity = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func spawn_projectiles(facing_left, x, y):
	for i in projectile_count:
		var projectile = projectile_scene.instantiate()
		projectile.speed = projectile_speed
		
		if !facing_left: projectile.rotation = PI
		else: projectile.rotation = 0
		projectile.rotation += randf_range(-projectile_spread, projectile_spread)
		projectile.position.x = x
		projectile.position.y = y + 4
		add_child(projectile)

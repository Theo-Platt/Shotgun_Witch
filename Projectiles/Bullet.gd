extends Area2D

@export var speed  = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	speed += randf_range(-10,10)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.x * speed * delta
	pass


func _on_visible_on_screen_notifier_2d_screen_exited():
	print("Bullet Offscreen")
	queue_free()
	pass # Replace with function body.

func _on_body_entered(body):
	print("Bullet Collision")
	queue_free()
	pass # Replace with function body.

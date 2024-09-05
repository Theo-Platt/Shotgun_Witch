extends RigidBody2D


@export var player = CharacterBody2D
var mirror_sprite                                           # bool:   keeps track of sprite direction

#####################
# Utility Functions #
#####################
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("shade")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

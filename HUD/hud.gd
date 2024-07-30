extends CanvasLayer
# See: https://docs.godotengine.org/en/stable/getting_started/first_2d_game/06.heads_up_display.html 
signal start_game

func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()


func _on_message_timer_timeout():
	$Message.hide()

func show_message(message):
	$Message.text = message
	$Message.show()
	pass

func game_over():
	show_message("Game Over")
	await $Timer.timeout
	
	$Message.text = "Shotgun Witch"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$"Score Tracker/Score_Label".text = str(score)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func Health_Tracker(health):
	var health_values = ["Empty Health","Low Health","Partial Health","Full Health"]
	$"Health Tracker".animation = health_values[health]
	$"Health Tracker".play()

func Ammo_Tracker(ammo):
	var ammo_notifs= [$"Ammo Tracker/shell1",$"Ammo Tracker/shell2",$"Ammo Tracker/shell3"]
	for tracker in ammo_notifs:
		if ammo > 0:
			ammo-=1
			tracker.Animation.Frame = 0
		else:
			tracker.Animation.Frame = 1


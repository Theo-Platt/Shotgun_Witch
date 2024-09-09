extends CanvasLayer
# See: https://docs.godotengine.org/en/stable/getting_started/first_2d_game/06.heads_up_display.html 
####################
# OutBound Signals #
####################
signal start_game


####################
# Public Variables #
####################


#####################
# Private Variables #
#####################
var score = 0

###################
# Signal Handlers #
###################
# start button pressed
func _on_start_button_pressed():
	$"Health Tracker".animation="Full Health"
	$"Health Tracker".play()
	for child in $"Ammo Tracker".get_children():
		child.hide()
	$StartButton.hide()
	$Message.hide()
	for child in $"Ammo Tracker".get_children():
		child.show()
	start_game.emit()


###############
# Game Ending #
###############
func game_over():
	show_message("Game Over")
	await get_tree().create_timer(5).timeout
	
	$Message.text = "Shotgun Witch"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(2).timeout
	$StartButton.show()


###############
# HUD Control #
###############
# controls the message label
func show_message(message):
	$Message.text = message
	$Message.show()
	pass

# controls the score label
func update_score(new_score):
	$"Score Tracker/Score_Label".text = str(new_score)

# controls the health sprite
func update_health(health):
	var health_values = ["Empty Health","Low Health","Partial Health","Full Health"]
	$"Health Tracker".animation = health_values[health]
	$"Health Tracker".play()
	print("Setting health tracker to '"+health_values[health]+"'")

# controls ammo sprites
func update_ammo(ammo):
	var ammo_notifs= [$"Ammo Tracker/shell1",$"Ammo Tracker/shell2",$"Ammo Tracker/shell3"]
	for tracker in ammo_notifs:
		if ammo > 0:
			ammo-=1
			tracker.frame = 0
		else:
			tracker.frame = 1

###########
# Utility #
###########
# Called when the node enters the scene tree for the first time.
func _ready():
	$StartButton.hide()
	for child in $"Ammo Tracker".get_children():
		child.hide()
	$Message.text = "Shotgun Witch"
	$Message.show()
	$"Health Tracker".animation="Full Health"
	$"Health Tracker".play()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$"Health Tracker".play()


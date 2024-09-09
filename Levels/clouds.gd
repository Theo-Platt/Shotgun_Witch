extends ParallaxLayer
@export var wind_speed = -.2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.motion_offset.x += wind_speed * delta * (1/0.0334)

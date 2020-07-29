extends Camera2D


export (float) var speed = 20
export (Vector2) var zoom_min_max
export (float) var zoom_speed
var target_zoom := zoom

func _physics_process(delta):
	var input := Vector2()
	if Input.is_action_pressed("right"):
		input += Vector2.RIGHT
	if Input.is_action_pressed("left"):
		input += Vector2.LEFT
	if Input.is_action_pressed("up"):
		input += Vector2.UP
	if Input.is_action_pressed("down"):
		input += Vector2.DOWN
	
	if Input.is_action_just_released("zoom_in"):
		target_zoom -= Vector2(zoom_speed, zoom_speed) * zoom.x
	if Input.is_action_just_released("zoom_out"):
		target_zoom += Vector2(zoom_speed, zoom_speed) * zoom.y
	target_zoom.x = clamp(target_zoom.x, zoom_min_max.x, zoom_min_max.y)
	target_zoom.y = target_zoom.x
	zoom = lerp(zoom, target_zoom, 0.25)
	
	
	translate((input.normalized() * speed) * zoom.x)

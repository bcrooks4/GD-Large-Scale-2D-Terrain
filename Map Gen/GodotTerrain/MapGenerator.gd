extends Node2D



export (Vector2) var size : Vector2
export (int) var subdivisions : int

export (Color) var water_colour : Color
export (Color) var grass_colour : Color
export (bool) var border := false

var noise := OpenSimplexNoise.new()
export var randomise_seed : bool
export var noise_seed : int                    
export (int, 1, 9) var noise_octaves : int    
export (int) var noise_period : int                
export (float, 0, 1) var noise_persistence : float
export var noise_lacunarity : float

export (float, 0, 1) var sea_height : float 

var thread := Thread.new()

func _ready():
	if randomise_seed:
		randomize()
		noise_seed = randi()
	SetUpNoise()
	#sprite.texture = GenerateImage()
	thread.start(self, "Generate", noise)

func _process(delta):
	pass
#	if Input.is_action_just_released("ui_accept"):
#		noise_seed += 1
#		SetUpNoise()
#		if !thread.is_active():
#			thread.start(self, "Generate", noise)

func Generate(thread_noise):
	for sprite in get_children():
		if sprite is Sprite:
			sprite.queue_free()
	
	thread_noise
	
	var image_size := size / subdivisions
	
	for x in range(subdivisions):
		for y in range(subdivisions):
			var sprite := Sprite.new()
			
			sprite.texture = GenerateImage(x, y, thread_noise)
			
			sprite.position = Vector2(x, y) * image_size
			add_child(sprite)

func SetUpNoise():
	noise.seed = noise_seed
	noise.octaves = noise_octaves
	noise.period = noise_period
	noise.persistence = noise_persistence
	noise.lacunarity = noise_lacunarity

func GetBoxFalloff(height : float, x : int, y : int) -> float:
	var xDist = (max(x, size.x / 2) - min(x, size.x / 2)) / size.x#(x / size.x * 2 - 1) 
	var yDist = (max(y, size.y / 2) - min(y, size.y / 2)) / size.y#(y / size.y * 2 - 1) 
	var g = max(abs(xDist), abs(yDist))
	g *= 1.1
	return height * (1 - g)

func GetPixel(x : int, y : int, thread_noise) -> Color:
	var h = (thread_noise.get_noise_2d(x, y) + 1) / 2
	h = GetBoxFalloff(h, x, y)
	var d = max(h, sea_height) - min(h, sea_height)
	if border:
		return (Color.black if (d < 0.002) else grass_colour if h > sea_height else water_colour)
	else:
		return grass_colour if h > sea_height else water_colour

func GenerateImage(xpos, ypos, thread_noise) -> ImageTexture:
	var image_size := size / subdivisions
	var image_texture := Image.new()
	image_texture.create(image_size.x, image_size.y, false, Image.FORMAT_RGB8)
	
	var centre := size / 2
	
	xpos *= image_size.x
	ypos *= image_size.y
	
	image_texture.lock()
	for x in range(image_size.x):
		for y in range(image_size.y):
			image_texture.set_pixel(x, y, GetPixel(xpos + x, ypos + y, thread_noise))
	image_texture.unlock()
	
	
	var texture := ImageTexture.new()
	texture.create_from_image(image_texture, texture.FLAG_MIPMAPS)
	return texture

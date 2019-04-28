extends TextureRect

const PROJECTILE = preload("projectile.tscn")

var lifes = 10
onready var life_sprite = $life_sprite
onready var life_counter = $life_counter
onready var time_counter = $time_counter



func add_life():
	lifes += 1
	life_counter.text = str(lifes)
	
func remove_life():
	lifes -= 1
	life_counter.text = str(lifes)
	if lifes <= 0:
		get_tree().paused = true

func _ready():
	game.level = self
	timer()
	while is_inside_tree():
		yield(get_tree().create_timer(0.52), "timeout")
		var p = PROJECTILE.instance()
		add_child(p)
		p.position = Vector2(
			rand_range(100, 1780),
			rand_range(0, 50)
		)
		p.applied_force = Vector2(0, 475)
		
func timer():
	var started = OS.get_system_time_secs()
	var last_reported = ""
	while is_inside_tree():
		var now = OS.get_system_time_secs()
		var delta = now - started
		var text = time.format_seconds(delta)
		if text != last_reported:
			last_reported = text
			time_counter.text = last_reported
		yield(time, "idle")
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

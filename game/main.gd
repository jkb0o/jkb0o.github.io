extends Control

const PROJECTILE = preload("projectile.tscn")
const Projectile = preload("projectile.gd")

onready var life_sprite = $bg/life_sprite
onready var life_counter = $bg/life_counter
onready var time_counter = $bg/time_counter

var lifes = 3
var delay = 2
var trails = {}



func add_life():
	lifes += 1
	life_counter.text = str(lifes)
	
func remove_life():
	lifes -= 1
	life_counter.text = str(lifes)
	if lifes <= 0:
		queue_free()
		get_tree().root.add_child(load("res://main.tscn").instance())
	
		
func add_trail(projectile):
	var trail = preload("res://trail.tscn").instance()
	add_child(trail)
	move_child(trail, 0)
	var points = []
	while is_instance_valid(projectile):
		yield(time, "idle")
		if !is_instance_valid(projectile):
			break
		trail.global_position = Vector2()
		if !(projectile is Projectile): # WTF???
			break
		points.insert(0, projectile.global_position)
		while points.size() > projectile.trail_size:
			points.pop_back()
		print(projectile.trail_size, " ", points.size())
		var c = Curve2D.new()
		while trail.get_point_count():
			trail.remove_point(0)
		for p in points:
			trail.add_point(p)
	yield(tw.ip(trail, "modulate:a", 1, 0, 0.5), "tween_completed")
	trail.queue_free()
func remove_projectile(p):
	p.queue_free()
func _ready():
#	$budha/bodybox/body.gravity_scale = 0
#	$budha/bodybox/body/body_sprt.modulate.a = 0
#	$budha/mind/orbit/orbit_sprt.modulate.a = 0
#	$budha/mind/shine_sprt.modulate.a = 0
#	#$budha/shine_sprt.modulat
#	#$budha.modulate.a = 0
#	yield(tw.ip($budha, "modulate:a", 0.2, 1, 3), "tween_completed")
#
#	var bt = 0.2
#	tw.ip($budha/mind/shine_sprt, "scale", Vector2(0.5, 0.5), Vector2(1.1, 1.1), bt*0.8)
#	tw.ip($budha/mind/shine_sprt, "scale", Vector2(1.1, 1.1), Vector2(1,1), bt*0.2, tw.SINE, tw.INOUT, bt*0.8)
#	tw.ip($budha/mind/shine_sprt, "modulate:a", 0, 1, bt)
#	yield(time.wait(bt), "completed")
#
#	bt = 2
#
#	var center = rect_size.y * 0.5
#	var delta = center - $budha.position.y
#	tw.ip($budha/mind/orbit/orbit_sprt, "modulate:a", 0, 1, bt)
#	tw.ip($budha, "position:y", $budha.position.y, center-delta*0.5, bt*0.5, tw.CUBIC, tw.IN)
#	tw.ip($budha, "position:y", center-delta*0.5, center, bt*0.5, tw.BACK, tw.OUT, bt*0.5)
#	tw.ip($budha/head_sprt, "scale:y", 1, 0.9, bt*0.1, tw.SINE, tw.OUT, bt*0.6)
#	tw.ip($budha/head_sprt, "scale:y", 0.9, 1, bt*0.1, tw.SINE, tw.OUT, bt*0.7)
#	tw.ip($budha/head_sprt, "scale:x", 1, 1.1, bt*0.1, tw.SINE, tw.OUT, bt*0.6)
#	tw.ip($budha/head_sprt, "scale:x", 1.1, 1, bt*0.1, tw.SINE, tw.OUT, bt*0.7)
#	tw.ip($budha/head_sprt, "scale:y", 1, 1.1, bt*0.1, tw.SINE, tw.OUT, bt*0.8)
#	tw.ip($budha/head_sprt, "scale:y", 1.1, 1, bt*0.1, tw.SINE, tw.OUT, bt*0.9)
#	tw.ip($budha/head_sprt, "scale:x", 1, 0.9, bt*0.1, tw.SINE, tw.OUT, bt*0.8)
#	tw.ip($budha/head_sprt, "scale:x", 0.9, 1, bt*0.1, tw.SINE, tw.OUT, bt*0.9)
#	tw.ip($budha/bodybox/body/body_sprt, "modulate:a", 0, 1, bt*0.5)
#	tw.ip($budha/bodybox/body/body_sprt, "global_position:y", 
#		$budha/bodybox/body/body_sprt.global_position.y + delta*2,
#		$budha/bodybox/body/body_sprt.global_position.y + delta*1.5,
#		bt*0.5, tw.CUBIC, tw.IN
#	)
#	tw.ip($budha/bodybox/body/body_sprt, "global_position:y", 
#		$budha/bodybox/body/body_sprt.global_position.y + delta*1.5,
#		$budha/bodybox/body/body_sprt.global_position.y + delta,
#		bt*0.5, tw.BACK, tw.OUT, bt*0.5
#	)
#	yield(time.wait(bt), "completed")
#
#	bt = 1
#	tw.ip($budha/mind, "modulate:a", 0, 1, bt)
#	yield(time.wait(bt), "completed")

	#$budha.position.y -= 100
	
	
	for w in $walls.get_children():
		w.connect("body_entered", self, "remove_projectile")
	game.level = self
	timer()
	while is_inside_tree():
		yield(get_tree().create_timer(delay), "timeout")
		delay = max(0.5, delay - 0.1)
		var p = PROJECTILE.instance()
		add_child(p)
		p.position = Vector2(
			rand_range(100, 1780),
			rand_range(-200, -100)
		)
		p.applied_force = Vector2(0, 475)
		var marker = Sprite.new()
		var tex = preload("res://textures/thought_marker.png")
		marker.texture = tex
		add_child(marker)
		marker.position = Vector2(
			p.position.x,
			tex.get_height()*0.5
		)
		var t = tw\
			.ip(marker, "modulate:a", 0, 1, 0.1)\
			.ip(marker, "modulate:a", 1, 0, 0.1, tw.SINE, tw.INOUT, 0.1)
		t.repeat = true
		time.wait(0.6).connect("completed", marker, "queue_free")
		
func bg():
	while is_inside_tree():
		var p =  life_sprite.get_viewport_transform() * Vector2()
		print(p, " ", life_sprite.global_position, " ", $budha.global_position)
		yield(time, "idle")
		
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

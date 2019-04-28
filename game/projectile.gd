extends RigidBody2D
var orbit
var joint

var points = []

func _ready():
	set_physics_process(false)
	var trail = preload("res://trail.tscn").instance()
	connect("tree_exited", trail, "queue_free")
	game.level.add_child(trail)
	game.level.move_child(trail, 0)

	while is_inside_tree():
		yield(time, "idle")
		trail.global_position = Vector2()
		points.insert(0, global_position)
		if points.size() > 25:
			points.pop_back()
		var c = Curve2D.new()
		while trail.get_point_count():
			trail.remove_point(0)
		for p in points:
			trail.add_point(p)

			
			
		
	
	
var _acceleration_progress = 0;
func _physics_process(delta):
	if orbit:
		var normal:Vector2 = (global_position - orbit.global_position).normalized()
		normal = normal.rotated(PI*0.5)
		if normal.dot(linear_velocity.normalized()) < 0:
			normal *= -1
		applied_force = normal * 450
		return
	var dir = game.level.life_sprite.global_position - global_position
	if dir.length() < 10:
		game.level.add_life()
		queue_free()
		return
	var vel = dir.normalized() * 1000 * (0.5 + 0.5*_acceleration_progress)
	linear_velocity = linear_velocity.linear_interpolate(vel, _acceleration_progress)
	_acceleration_progress += delta * 0.1
	#applied_force = dir.normalized() * 100
	
func remove():
	pass
	
func set_orbit(o):
	orbit = o
	var t = Tween.new()
	add_child(t)
	t.start()
	t.interpolate_property($spikes, "scale", Vector2(1,1), Vector2(0,0), 1, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	set_physics_process(true)
	
func move_to_lifes():
	orbit = null
	set_physics_process(true)

func _move_to_lifes():
	var t = Tween.new()
	add_child(t)
	var n = Node2D.new()
	game.level.add_child(n)
	n.global_position = global_position
	t.interpolate_property(n, "global_position", global_position, game.level.life_sprite.global_position, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	t.follow_property(self, "global_position", global_position, n, "global_position", 2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	t.start()
	yield(t, "tween_completed")
	game.level.add_life()
	queue_free()

extends RigidBody2D
var orbit
var joint
export var trail_size = 25

var points = []

func _ready():
	set_physics_process(false)
	game.level.add_trail(self)

			
			
		
	
	
var _acceleration_progress = 0;
func _physics_process(delta):
	if orbit:
		var normal:Vector2 = (global_position - orbit.global_position).normalized()
		normal = normal.rotated(PI*0.5)
		if normal.dot(linear_velocity.normalized()) < 0:
			normal *= -1
		applied_force = normal * 450
		
		var life_dir = game.level.life_sprite.global_position - global_position
		var life_dot = life_dir.normalized().dot(linear_velocity.normalized())
		if life_dot > 0.95:
			clear_orbit()
		return
	var dir = game.level.life_sprite.global_position - global_position
	if dir.length() < 10:
		game.level.add_life()
		queue_free()
		return
	var vel = dir.normalized() * 1000 * (0.5 + 0.5*_acceleration_progress)
	linear_velocity = linear_velocity.linear_interpolate(vel, _acceleration_progress)
	_acceleration_progress += delta * 0.1
	$heart.global_rotation = 0
	#applied_force = dir.normalized() * 100
	
func clear_orbit():
	orbit = null
	joint.queue_free()
	$flash.show()
	$flash.modulate.a = 0
	$flash.scale = Vector2()
	var ft = 0.2
	tw.ip($flash, "scale", Vector2(), Vector2(1,1), ft, tw.CUBIC, tw.IN)
	tw.ip($flash, "modulate:a", 0, 1, ft)
	yield(time.wait(ft), "completed")
	for n in [$spikes, $spikes_white, $face, $face_white]:
		n.hide()
	$heart.show()
	#tw.ip($flash, "scale", Vector2(), Vector2(1,1), ft, tw.CUBIC, tw.IN)
	tw.ip($flash, "modulate:a", 1, 0, 0.5)
	
func remove():
	pass
	
func set_orbit(o):
	orbit = o
	#var t = Tween.new()
	#add_child(t)
	#t.start()
	#t.interpolate_property($spikes, "scale", Vector2(1,1), Vector2(0,0), 1, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tw.ip(self, "trail_size", trail_size, 0, 0.5, tw.SINE, tw.INOUT)
	for n in [$spikes_white, $face_white]:
		n.modulate.a = 0
		n.show()
		tw.ip(n, "modulate:a", 0, 1, 1)
	for n in [$spikes, $spikes_white]:
		tw.ip(n, "scale", Vector2(1,1), Vector2(0.5, 0.5), 0.75, tw.CUBIC, tw.IN)
	
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

extends "circle.gd"

const Projectile = preload("projectile.gd")

export var breaking_gap = 50
export var joining_gap = 50

onready var mind = $mind
onready var orbit = $mind/orbit
onready var center = $mind/orbit/center
#onready var orbit = $orbit
onready var mind_joint = $joint





func _ready():
	orbit.connect("body_entered", self, "try_add_to_orbit")
	orbit.connect("body_exited", self, "remove_from_orbit")
	#orbit.connect("area_entered", self, "add_to_orbit")
	connect("body_entered", self, "remove_life")
	
func remove_life(projectile:RigidBody2D):
	remove_from_orbit(projectile)
	projectile.remove()
	game.level.remove_life()
	
var projectiles_to_check = []
func remove_from_orbit(projectile:Projectile):
	if projectiles_to_check.has(projectile):
		projectiles_to_check.erase(projectile)
	
func try_add_to_orbit(projectile:RigidBody2D):
	projectiles_to_check.append(projectile)
	
	
func add_to_orbit(projectile:Projectile):
	var j = PinJoint2D.new()
	#return
#	var j = DampedSpringJoint2D.new()
	j.disable_collision = true
	center.add_child(j)
	#j.position.y = - 20
	j.softness = 20
	
	j.node_a = j.get_path_to(center)
	j.node_b = j.get_path_to(projectile)
	#j.rest_length = global_position.distance_to(projectile.global_position)
	#j.length = j.rest_length
	#j.initial_offset = 0
#	j.stiffness = 20
	projectile.joint = j
	projectile.applied_force = Vector2()
	projectile.collision_mask = 0
	projectile.collision_layer = 0
	projectile.set_orbit(orbit)
	#get_tree().create_timer(2).connect("timeout", self, "add_lifes", [projectile, j])

	
func _physics_process(delta):
	rotation_degrees = 0
	var to_remove = []
	for projectile in projectiles_to_check:
		var vel = projectile.linear_velocity.normalized()
		var dir = (orbit.global_position - projectile.global_position).normalized()
		print(dir, " ", orbit.global_position, " ", projectile.global_position, " ", vel.dot(dir))
		if abs(vel.dot(dir)) < 0.5:
			add_to_orbit(projectile)
			to_remove.append(projectile)
	for p in to_remove:
		projectiles_to_check.erase(p)
	#var dist = small.position.distance_to(big.position)
	#print(small.position.distance_to(big.position))


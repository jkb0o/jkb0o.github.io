tool
extends RigidBody2D

export var force_value = 10;
export (String, "left", "right") var stick = "right"

var strength = Vector2()


func _ready():
	print(get_name())
	
func _physics_process(delta):
	#strength = get_input_strength()
#		print(strength, Input.get_action_strength("%s_stick_right" % stick), " ", Input.get_action_strength("left_stick_right"))
	applied_force = strength * force_value
	


func get_input_strength():
 	return Vector2(
		Input.get_action_strength("%s_stick_right" % stick) - Input.get_action_strength("%s_stick_left" % stick),
		Input.get_action_strength("%s_stick_down" % stick) - Input.get_action_strength("%s_stick_up" % stick)
	)
func _input(event):
	strength = get_input_strength()
		

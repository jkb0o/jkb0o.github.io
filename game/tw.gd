extends Node

enum {
	LINEAR = Tween.TRANS_LINEAR,
	SINE = Tween.TRANS_SINE,
	CUBIC = Tween.TRANS_CUBIC,
	BACK = Tween.TRANS_BACK
}

enum {
	IN = Tween.EASE_IN,
	OUT = Tween.EASE_OUT,
	INOUT = Tween.EASE_IN_OUT,
	OUTIN = Tween.EASE_OUT_IN
}

const ANY=Engine

func ip(obj, prop, from, to, duration, trans=Tween.TRANS_LINEAR, easing=Tween.EASE_IN_OUT, delay=0):
	var tw = Tw.new()
	add_child(tw)
	tw.start()
	return tw.ip(obj, prop, from, to, duration, trans, easing, delay)

func ait(time):
	return get_tree().create_timer(time)


class Tw:
	extends Tween
	var timer
	var last_duration = -1
	
	func _ready():
		connect("tween_completed", self, "check")
		
	func check(object, key):
		if tell() >= get_runtime():
			queue_free()
	
	func ip(obj, prop, from, to, duration, trans=Tween.TRANS_LINEAR, easing=Tween.EASE_IN_OUT, delay=0):
		last_duration = duration
		interpolate_property(obj, prop, from, to, duration, trans, easing, delay)
		return self
		
	func ic(obj, cb, duration=null, arg0=ANY, arg1=ANY, arg2=ANY, arg3=ANY, arg4=ANY):
		if duration == null:
			duration = last_duration
		if arg0 == ANY:
			interpolate_callback(obj, duration, cb)
		elif arg1 == ANY:
			interpolate_callback(obj, duration, cb, arg0)
		elif arg2 == ANY:
			interpolate_callback(obj, duration, cb, arg0, arg1)
		elif arg3 == ANY:
			interpolate_callback(obj, duration, cb, arg0, arg1, arg2)
		elif arg4 == ANY:
			interpolate_callback(obj, duration, cb, arg0, arg1, arg2, arg3)
		else:
			interpolate_callback(obj, duration, cb, arg0, arg1, arg2, arg3, arg4)
		return self


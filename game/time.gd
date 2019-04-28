extends Node

signal idle
signal fixed

const FORMAT_SECONDS_FULL = 0 
const FORMAT_SECONDS_NORMAL = 1
const FORMAT_SECONDS_TINY = 2

func _ready():
	get_tree().connect("idle_frame", self, "emit_signal", ["idle"])
	get_tree().connect("physics_frame", self, "emit_signal", ["fixed"])
	
func wait(time):
	yield(get_tree().create_timer(time), "timeout")

# wait with respect paused branch 
# of current (at the moment of call) screen
	
func now():
	return OS.get_system_time_msecs()*0.001

func defer():
	var d = _Deferred.new()
	yield(d.process(), "completed")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func period_to_seconds(period):
	if typeof(period) == TYPE_INT || typeof(period) == TYPE_REAL:
		return float(period)
	var result = 0
	var amount = ""
	for index in range(period.length()):
		var ch = period.substr(index, 1)
		if ch == "." || ch.is_valid_integer():
			amount += ch
			continue
		elif ch == "s":
			result += amount.to_float()
		elif ch == "m":
			result += 60 * amount.to_float()
		elif ch == "h":
			result += 60 * 60 * amount.to_float()
		elif ch == "d":
			result += 60 * 60 * 24 * amount.to_float()
		amount = ""
	return max(0.1,result)

const D = 60*60*24
const H = 60*60
const M = 60
func format_seconds(t,mode=FORMAT_SECONDS_TINY):
	t = int(t)
	var d = 0
	#if mode == FORMAT_SECONDS_FULL:
	#	d = t / D
	#	if d >= with_days:
	#		t -= d * D
	#	else:
	#		d = 0
	var h = t / H
	var m = (t % H) / 60
	var s = t % M
	
	var res = ""
	if d:
		res = str(d) + " " + tr(pluralize("days", d))
	elif h:
		res = str(h).pad_zeros(2) + ":" + str(m).pad_zeros(2)
		if mode != FORMAT_SECONDS_TINY:
			res += ":" + str(s).pad_zeros(2)
	else:
		res = str(m).pad_zeros(2) + ":" + str(s).pad_zeros(2)
	#while res.begins_with("0"):
	#	res = res.substr(1, res.length())
	return res

func format_period(p):
	return format_seconds(period_to_seconds(p))
func format_now(format="%Y.%m.%d %H:%M:%S"):
	return format_time(now(), format)
func format_time(time, format="%Y.%m.%d %H:%M:%S"):
# more in http://www.cplusplus.com/reference/ctime/strftime/
	var data = OS.get_datetime_from_unix_time(floor(time))
	var result = ""
	var i = 0
	var token = false
	while i < format.length():
		if format[i] == '%':
			token = true
			i += 1
			continue
		else:
			if token:
				match format[i]:
					'Y':
						result += "%04d" % data.year
					'm':
						result += "%02d" % data.month
					'd':
						result +="%02d" % data.day
					'H':
						result +="%02d" % data.hour
					'M':
						result +="%02d" % data.minute
					'S':
						result +="%02d" % data.second
					'f': # C# like, cuz it's missing but usefull
						result +="%03d" % (int(1000*time) % 1000)
					'z': # C# like, cuz it's more representative
						result +="%+02d:00" % (OS.get_time_zone_info().bias/60)
				token = false
			else:
				result += format[i]
		i += 1
	return result


# 1 день													- _SOLO
# 21, 101 день									  - _SINGLE
# 2, 3, 4, 22, 102 дня						- _DOUBLE
# 5, 6, 11, 12, 20, 30, 110 дней	- _TRIPLE
func pluralize(key, number):
	var suffix
	number = int(round(number))
	var left = number % 10
	if number == 1: 
		suffix = "_SOLO"
	elif (number >= 5 && number <= 20) || left == 0 || left >= 5:
		suffix = "_TRIPLE"
	elif left == 1:
		suffix = "_SINGLE"
	else:
		suffix = "_DOUBLE"
	return key.to_upper() + suffix


class _Deferred:
	extends Reference
	signal defer
	
	func process():
		call_deferred("emit_signal", "defer")
		yield(self, "defer")
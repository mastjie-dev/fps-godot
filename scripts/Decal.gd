extends Spatial

func spawn(pos, fx, fz, rx, rz):
	transform.origin = pos
	if fx:
		rotate_x(deg2rad(90))
	elif fz:
		rotate_y(deg2rad(90))
	else:
		rotate_y(1-rz)
		rotate_x(1-rx)

func _on_Timer_timeout():
	queue_free()

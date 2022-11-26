extends KinematicBody

signal walk
signal shoot
signal enemy_destroyed
signal spray_decal(pos, x, z)

enum Anim_State { IDLE, SHOOT, DOWN, UP }

var mouse_sensitivity := .1
var play_state := false
var speed := 10
var gravity := 9.8
var jump_power = 5
var velocity := Vector3.ZERO
var direction := Vector3.ZERO
var snap := Vector3.DOWN
var anim_state = Anim_State.IDLE

func surface_normal(ray: RayCast):
	ray.force_raycast_update()
	if ray.is_colliding():
		return ray.get_collision_normal()
	return Vector3.ZERO
	
func surface_axis(v1: Vector3, v2: Vector3, axis: Vector3):
	var a = abs(v1.round().dot(axis))
	var b = abs(v2.round().dot(axis))
	return a and b
	
func _input(event):
	if play_state and event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		$Head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		$Head.rotation.x = clamp($Head.rotation.x, deg2rad(-90), deg2rad(90))

func _physics_process(delta):
	if !play_state:
		return
	direction.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var _y = velocity.y
	velocity = Vector3.ZERO
	
	direction = direction.normalized()
	velocity += transform.basis.z * direction.z
	velocity += transform.basis.x * direction.x
	velocity *= speed
	velocity.y = _y - (gravity * delta)
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = jump_power
		snap = Vector3.ZERO
	elif is_on_floor() and snap == Vector3.ZERO:
		snap = Vector3.DOWN
	
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true)
	if (velocity.x != 0 || velocity.z != 0) && is_on_floor():
		emit_signal("walk")
	
	if Input.is_action_just_released("click") && anim_state == Anim_State.IDLE:
		anim_state = Anim_State.SHOOT
		$Head/Gun/AnimationPlayer.play("Recoil")
		emit_signal("shoot")
		var ray = $Head/MainRay
		ray.force_raycast_update()
		if ray.is_colliding():
			var body = ray.get_collider()
			if body.is_in_group("enemies"):
				body.queue_free()
				emit_signal("enemy_destroyed")
			var point = ray.get_collision_point()
			var top_normal = surface_normal($Head/TopRay)
			var bottom_normal = surface_normal($Head/BottomRay)
			var right_normal = surface_normal($Head/RightRay)
			var left_normal = surface_normal($Head/LeftRay)
			var rad_x = top_normal.dot(bottom_normal)
			var rad_z = right_normal.dot(left_normal)
			var flip_z = surface_axis(right_normal, left_normal, Vector3.RIGHT)
			var flip_x = surface_axis(top_normal, bottom_normal, Vector3.UP)
			
			emit_signal("spray_decal", point, flip_x, flip_z, rad_x, rad_z)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Recoil":
		anim_state = Anim_State.IDLE
	elif anim_name == "Gunup":
		anim_state = Anim_State.IDLE

func _on_GunTip_body_entered(_body):
	anim_state = Anim_State.DOWN
	$Head/Gun/AnimationPlayer.play("Gundown")

func _on_GunTip_body_exited(_body):
	anim_state = Anim_State.UP
	$Head/Gun/AnimationPlayer.play("Gunup")

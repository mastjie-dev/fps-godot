extends Node

var Decal = preload("res://Decal.tscn")

enum States { PLAY, PAUSE }
var state = States.PAUSE
var enemy_count = 5

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && state == States.PLAY:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			state = States.PAUSE
			$Player.play_state = false
			$UI/Overlay.show()

func _on_Spray_decal(pos, fx, fz, rx, rz):
	var decal = Decal.instance()
	add_child(decal)
	decal.spawn(pos, fx, fz, rx, rz)

func _on_Timer_timeout():
	$Player.play_state = true

func _on_Player_shoot():
	$AudioManager.play_shoot_audio()

func _on_Player_walk():
	$AudioManager.play_walk_audio()

func _on_UI_button_pressed():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE && state == States.PAUSE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		state = States.PLAY
		$Timer.start()

func _on_Player_enemy_destroyed():
	enemy_count -= 1
	if enemy_count == 0:
		$Player.play_state = false
		$UI/Overlay.show()
		$UI/Overlay/Label.show()
		$UI/Overlay/PlayButton.hide()

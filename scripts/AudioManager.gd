extends Node

func play_shoot_audio():
	$Shoot.play()

func play_walk_audio():
	if $Timer.time_left <= 0:
		$Walk.play()
		$Timer.start()

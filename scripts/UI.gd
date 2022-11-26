extends Control

signal button_pressed

func _ready():
	$Overlay/Label.hide()

func _on_Button_pressed():
	$Overlay.hide()
	emit_signal("button_pressed")
	

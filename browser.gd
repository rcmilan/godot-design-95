extends Node2D

func _ready() -> void:
	$ExeIcon.pressed.connect(_on_icon_pressed)
	$BrowserWindow/VBox/TitleBar/TitleHBox/Close.pressed.connect(_on_close_pressed)

func _on_icon_pressed() -> void:
	$BrowserWindow.visible = true

func _on_close_pressed() -> void:
	$BrowserWindow.visible = false

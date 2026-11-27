extends CanvasLayer
signal started
@onready var menu_panel: Control = $Dim/Panel
@onready var howto_panel: Control = $Dim/HowToPanel

@onready var play_button: Button = $Dim/Panel/Margin/VBox/PlayButton
@onready var howto_button: Button = $Dim/Panel/Margin/VBox/HowToButton
@onready var quit_button: Button = $Dim/Panel/Margin/VBox/QuitButton
@onready var back_button: Button = $Dim/HowToPanel/Margin/VBox/BackButton


func _ready() -> void:
	layer = 40
	menu_panel.visible = true
	howto_panel.visible = false

	play_button.pressed.connect(_on_play)
	howto_button.pressed.connect(_on_howto)
	quit_button.pressed.connect(_on_quit)
	back_button.pressed.connect(_on_back)


func _on_play() -> void:
	visible = false
	started.emit()

func _on_howto() -> void:
	menu_panel.visible = false
	howto_panel.visible = true


func _on_back() -> void:
	howto_panel.visible = false
	menu_panel.visible = true


func _on_quit() -> void:
	get_tree().quit()

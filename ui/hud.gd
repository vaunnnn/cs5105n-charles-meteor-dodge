extends CanvasLayer

signal restart_requested
signal main_menu_requested

@onready var objective: Label = %Objective
@onready var countdown: Label = %Countdown
@onready var message: Label = %Heading

func _ready() -> void:
	Settings.large_text_changed.connect(_apply_text_sizes)
	_apply_text_sizes()
	%Restart.pressed.connect(func() -> void: restart_requested.emit())
	%MainMenu.pressed.connect(func() -> void: main_menu_requested.emit())
	%Overlay.hide()
	update_stats(0, 0.0)

func _apply_text_sizes() -> void:
	Settings.apply_text_sizes($Root)

func update_stats(score: int, seconds: float) -> void:
	%Score.text = "SCORE  %06d" % score
	%Time.text = "SURVIVAL  %.1f s" % seconds

func show_result(score: int, seconds: float, victory: bool = false) -> void:
	%Heading.text = "MISSION COMPLETE!" if victory else "GAME OVER"
	%FinalScore.text = "FINAL SCORE  %06d" % score
	%FinalTime.text = "SURVIVAL TIME  %.1f seconds" % seconds
	%Hint.text = "Both levels survived. Enter to restart from Level 1." if victory else "Enter to restart this level"
	%Overlay.show()
	%Restart.grab_focus()

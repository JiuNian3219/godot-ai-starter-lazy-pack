extends Node2D

var _frames_seen := 0


func _ready() -> void:
	print("AI workflow smoke test: ready")


func _process(_delta: float) -> void:
	if DisplayServer.get_name() != "headless":
		return

	_frames_seen += 1
	if _frames_seen >= 3:
		print("AI workflow smoke test: completed")
		get_tree().quit()


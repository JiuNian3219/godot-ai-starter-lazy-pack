extends SceneTree


func _init() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		push_error("Smoke test failed: main scene did not load")
		quit(1)
		return

	var instance := scene.instantiate()
	if not instance is Node2D:
		push_error("Smoke test failed: main scene root is not Node2D")
		instance.free()
		quit(1)
		return

	print("Smoke test passed: main scene loads and instantiates")
	instance.free()
	quit()

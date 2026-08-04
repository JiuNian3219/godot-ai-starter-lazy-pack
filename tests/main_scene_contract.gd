extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")

var _failed := 0


## 验证模板主场景中必须保存的编辑器可见节点，防止用运行时代码替代场景结构。
func _init() -> void:
	var instance := MAIN_SCENE.instantiate()
	_assert(instance is Node2D, "main scene root must be Node2D")
	_assert(instance.get_node_or_null("Title") is Label, "main scene must persist a Label named Title")

	if _failed == 0:
		print("Main scene contract passed: persisted node structure is present")
	else:
		push_error("Main scene contract failed: %d assertion(s) failed" % _failed)

	instance.free()
	quit(_failed)


## 记录失败并让 SceneTree 以非零状态退出，避免验证脚本误报通过。
func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failed += 1
		push_error("ASSERT FAILED: " + message)

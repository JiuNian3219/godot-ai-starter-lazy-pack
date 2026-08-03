extends SceneTree

var _passed := 0
var _failed := 0


func _init() -> void:
	_test_default_values()
	_test_reset()
	_test_apply_damage()
	_test_heal()
	_test_is_dead()
	_test_died_signal_once()
	_test_heal_from_zero()
	_test_no_damage_when_dead()
	_test_zero_and_negative_damage()
	_test_zero_and_negative_heal()
	_test_max_health_change()
	_test_health_changed_signal()

	print("HealthComponent tests: %d passed, %d failed" % [_passed, _failed])
	quit(_failed)


func _assert(condition: bool, message: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		push_error("ASSERT FAILED: " + message)


func _make_component(max_health: int = 100) -> HealthComponent:
	var hc := HealthComponent.new()
	hc.max_health = max_health
	hc.reset()
	return hc


func _test_default_values() -> void:
	var hc := _make_component(50)
	_assert(hc.max_health == 50, "max_health should be 50")
	_assert(hc.current_health == 50, "current_health should be 50 after reset")
	hc.free()


func _test_reset() -> void:
	var hc := _make_component(100)
	hc.apply_damage(30)
	hc.reset()
	_assert(hc.current_health == 100, "current_health should reset to max")
	_assert(not hc.is_dead(), "should not be dead after reset")
	hc.free()


func _test_apply_damage() -> void:
	var hc := _make_component(100)
	hc.apply_damage(25)
	_assert(hc.current_health == 75, "health should be 75 after 25 damage")
	hc.free()


func _test_heal() -> void:
	var hc := _make_component(100)
	hc.apply_damage(40)
	hc.heal(10)
	_assert(hc.current_health == 70, "health should be 70 after healing 10")
	hc.free()


func _test_is_dead() -> void:
	var hc := _make_component(10)
	_assert(not hc.is_dead(), "should not be dead at start")
	hc.apply_damage(10)
	_assert(hc.is_dead(), "should be dead after taking 10 damage")
	hc.free()


func _test_died_signal_once() -> void:
	var hc := _make_component(10)
	var died_count := [0]
	hc.died.connect(func() -> void: died_count[0] += 1)
	hc.apply_damage(5)
	_assert(died_count[0] == 0, "died should not emit after 5 damage")
	hc.apply_damage(5)
	_assert(died_count[0] == 1, "died should emit once after reaching 0")
	hc.apply_damage(5)
	_assert(died_count[0] == 1, "died should not emit again when already dead")
	hc.free()


func _test_heal_from_zero() -> void:
	var hc := _make_component(10)
	hc.apply_damage(10)
	hc.heal(5)
	_assert(hc.current_health == 5, "healing from zero should revive to 5")
	_assert(not hc.is_dead(), "should not be dead after healing above zero")
	hc.free()


func _test_no_damage_when_dead() -> void:
	var hc := _make_component(10)
	hc.apply_damage(10)
	hc.apply_damage(5)
	_assert(hc.current_health == 0, "should not go below 0")
	hc.free()


func _test_zero_and_negative_damage() -> void:
	var hc := _make_component(100)
	hc.apply_damage(0)
	_assert(hc.current_health == 100, "zero damage should not change health")
	hc.apply_damage(-5)
	_assert(hc.current_health == 100, "negative damage should not change health")
	hc.free()


func _test_zero_and_negative_heal() -> void:
	var hc := _make_component(100)
	hc.heal(0)
	_assert(hc.current_health == 100, "zero heal should not change health")
	hc.heal(-5)
	_assert(hc.current_health == 100, "negative heal should not change health")
	hc.free()


func _test_max_health_change() -> void:
	var hc := _make_component(100)
	hc.heal(200)
	_assert(hc.current_health == 100, "heal should not exceed max_health")
	hc.free()


func _test_health_changed_signal() -> void:
	var hc := _make_component(100)
	var signal_calls: Array[Dictionary] = []
	hc.health_changed.connect(func(cur: int, mx: int) -> void:
		signal_calls.append({"current": cur, "max": mx})
	)
	hc.apply_damage(10)
	_assert(signal_calls.size() == 1, "health_changed should emit on damage")
	_assert(signal_calls[0]["current"] == 90, "signal should carry current 90")
	_assert(signal_calls[0]["max"] == 100, "signal should carry max 100")
	hc.free()

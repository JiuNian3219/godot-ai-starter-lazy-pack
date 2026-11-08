extends SceneTree

const BATTLE_SCENE := preload("res://scenes/prototypes/round_battle_prototype.tscn")

var _passed := 0
var _failed := 0


func _init() -> void:
	_run.call_deferred()


## 先检查持久 UI，再沿真实按钮入口验证异步回合的时间和状态边界。
func _run() -> void:
	var battle := BATTLE_SCENE.instantiate() as RoundBattlePrototype
	_assert(battle.get_node_or_null("StartRound") is Button, "button must be saved in the scene")
	_assert(battle.get_node_or_null("FirstAlly/Action") is Label, "first actor status must be persisted")
	_assert(battle.get_node_or_null("SecondAlly/Action") is Label, "second actor status must be persisted")
	_assert(battle.get_node_or_null("Enemy/Stats") is Label, "enemy stats must be persisted")
	root.add_child(battle)
	battle.start_button.pressed.emit()
	_assert(battle.round_running and battle.start_button.disabled, "round must lock immediately")
	_assert(battle.first_action.text == "行动中", "first actor must announce before damage")
	_assert(battle.second_action.text == "等待行动", "second actor must wait for first")
	battle.start_round()
	_assert(battle.round_number == 1, "repeated entry must not start another round")
	await create_timer(0.1).timeout
	_assert(battle.enemy_health == 9 and battle.enemy_shield == 4, "damage must not settle before 0.2 seconds")
	await _wait_for_first_hit(battle)
	_assert(battle.enemy_health == 8 and battle.enemy_shield == 0, "first hit must absorb 4 shield then deal 1 health")
	_assert(battle.second_action.text == "行动中", "second actor starts only after first damage settles")
	_assert(battle.start_button.disabled, "button stays disabled between actors")
	await create_timer(0.1).timeout
	_assert(battle.enemy_health == 8, "second actor also waits before damage")
	await _wait_for_round(battle)
	_assert(battle.enemy_health == 5, "second hit must deal attack minus defense")
	_assert(not battle.start_button.disabled, "completed nonlethal round must allow another click")
	battle.start_button.pressed.emit()
	await _wait_for_round(battle)
	_assert(battle.enemy_health == 0, "next round first actor must defeat enemy")
	_assert(battle.second_action.text == "未行动 · 敌人已倒下", "later actor must not act after death")
	_assert(battle.start_button.disabled, "finished battle cannot start another round")
	battle.start_round()
	_assert(battle.round_number == 2, "dead enemy must reject direct round entry")
	battle.free()

	battle = BATTLE_SCENE.instantiate() as RoundBattlePrototype
	battle.enemy_defense = 99
	battle.enemy_starting_shield = 5
	root.add_child(battle)
	battle.start_button.pressed.emit()
	await _wait_for_round(battle)
	_assert(battle.enemy_shield == 3, "each hit must deal at least 1 even below defense")
	_assert(battle.enemy_health == 9, "sufficient shield must prevent health damage")
	battle.free()

	battle = BATTLE_SCENE.instantiate() as RoundBattlePrototype
	battle.enemy_starting_health = 1
	battle.enemy_starting_shield = 0
	root.add_child(battle)
	battle.start_button.pressed.emit()
	await _wait_for_round(battle)
	_assert(battle.enemy_health == 0 and battle.enemy_shield == 0, "overkill must clamp health and shield to zero")
	_assert(not battle.battle_log.text.contains("角色 2"), "skipped actor must cause no damage log")
	battle.free()

	print("Round battle tests: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed else 0)


## 有界等待避免回合卡住时测试永久挂起；逐帧观察第一击的真实结算点。
func _wait_for_first_hit(battle: RoundBattlePrototype) -> void:
	var deadline := Time.get_ticks_msec() + 2000
	while battle.enemy_shield == 4 and Time.get_ticks_msec() < deadline:
		await process_frame
	_assert(battle.enemy_shield != 4, "first hit must settle within timeout")


## 等待真实回合完成，超时使测试失败，不用固定延迟假定完成。
func _wait_for_round(battle: RoundBattlePrototype) -> void:
	var deadline := Time.get_ticks_msec() + 2000
	while battle.round_running and Time.get_ticks_msec() < deadline:
		await process_frame
	_assert(not battle.round_running, "round must complete within timeout")


## 保留每项失败，并通过非零退出码传给统一验证脚本。
func _assert(condition: bool, message: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		push_error("ASSERT FAILED: " + message)

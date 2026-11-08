class_name RoundBattlePrototype
extends Control
## F6 运行本场景，或 F5 运行项目；验证顺序行动、延迟结算与击杀后中断。
## 调整下方攻击、防御、生命与护盾；通过条件由 tests/round_battle_test.gd 检查。

const ACTION_DELAY := 0.2

@export var first_ally_attack: int = 8
@export var second_ally_attack: int = 6
@export var enemy_defense: int = 3
@export var enemy_starting_health: int = 9
@export var enemy_starting_shield: int = 4

var enemy_health: int
var enemy_shield: int
var round_running := false
var round_number := 0

@onready var first_action: Label = $FirstAlly/Action
@onready var second_action: Label = $SecondAlly/Action
@onready var enemy_stats: Label = $Enemy/Stats
@onready var round_status: Label = $RoundStatus
@onready var battle_log: Label = $BattleLog
@onready var start_button: Button = $StartRound


## 初始战斗数据由本场景持有，UI 只显示这些数据。
func _ready() -> void:
	enemy_health = enemy_starting_health
	enemy_shield = enemy_starting_shield
	$FirstAlly/Stats.text = "攻击 %d" % first_ally_attack
	$SecondAlly/Stats.text = "攻击 %d" % second_ally_attack
	_update_enemy_display()


## 单个顺序循环保留等待与结算的先后关系；入口锁在第一次等待前生效。
func start_round() -> void:
	if round_running or enemy_health <= 0:
		return

	round_running = true
	start_button.disabled = true
	round_number += 1
	round_status.text = "第 %d 回合 · 执行中" % round_number
	first_action.text = "等待行动"
	second_action.text = "等待行动"
	battle_log.text = ""
	var attacks: Array[int] = [first_ally_attack, second_ally_attack]
	var actions: Array[Label] = [first_action, second_action]
	for index in range(attacks.size()):
		if enemy_health <= 0:
			actions[index].text = "未行动 · 敌人已倒下"
			break

		actions[index].text = "行动中"
		# SceneTreeTimer 仅为本次动作等待创建，超时后由引擎释放。
		await get_tree().create_timer(ACTION_DELAY).timeout
		var damage := maxi(1, attacks[index] - enemy_defense)
		var shield_damage := mini(enemy_shield, damage)
		var health_damage := mini(enemy_health, damage - shield_damage)
		enemy_shield -= shield_damage
		enemy_health -= health_damage
		actions[index].text = "行动完成 · 伤害 %d" % damage
		battle_log.text += "角色 %d：伤害 %d，护盾 -%d，生命 -%d\n" % [
			index + 1, damage, shield_damage, health_damage
		]
		_update_enemy_display()

	round_running = false
	start_button.disabled = enemy_health <= 0
	if enemy_health <= 0:
		round_status.text = "第 %d 回合 · 胜利，敌人已倒下" % round_number
		start_button.text = "战斗结束"
	else:
		round_status.text = "第 %d 回合结束 · 可以开始下一回合" % round_number


## 护盾与生命显示只在初始化或伤害结算后更新。
func _update_enemy_display() -> void:
	enemy_stats.text = "生命 %d    护盾 %d\n防御 %d" % [enemy_health, enemy_shield, enemy_defense]

class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 100:
	set(value):
		max_health = maxi(value, 1)
		current_health = mini(current_health, max_health)

var current_health: int = 100


func _ready() -> void:
	reset()


func reset() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func apply_damage(amount: int) -> void:
	if amount <= 0:
		return

	var was_alive := not is_dead()
	current_health = maxi(current_health - amount, 0)
	health_changed.emit(current_health, max_health)

	if was_alive and is_dead():
		died.emit()


func heal(amount: int) -> void:
	if amount <= 0:
		return

	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func is_dead() -> bool:
	return current_health <= 0

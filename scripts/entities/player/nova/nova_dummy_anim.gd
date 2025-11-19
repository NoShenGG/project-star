extends Node

signal attack_hit
signal attack_done
signal attack_charged_hit
signal attack_charged_done

func attack() -> void:
	await get_tree().create_timer(0.1).timeout
	attack_hit.emit()
	await get_tree().create_timer(0.3).timeout
	attack_done.emit()
	
func attack_charged() -> void:
	for i in range(3):
		await get_tree().create_timer(0.2).timeout
		attack_charged_hit.emit()
	await get_tree().create_timer(0.2).timeout
	attack_charged_done.emit()

extends Control

onready var staminaBar = $StaminaBar
var staminaDepleted = false

func drainStamina():
	visible = true
	if staminaBar.value > 0:
		staminaBar.value -= 0.4
	else:
		staminaDepleted = true
		get_tree().call_group("player", "setPlayerCanRun", false)

func rechargeStamina():
	if staminaBar.value < 100:
		if staminaDepleted:
			staminaBar.value += 0.3
		else:
			staminaBar.value += 0.5
	else:
		staminaDepleted = false
		get_tree().call_group("player", "setPlayerCanRun", true)
	
	if staminaDepleted:
		visible = true
	else:
		visible = false

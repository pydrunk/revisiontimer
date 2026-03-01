extends Control

enum state {revising, chilling, paused}

var current_state : state
@onready var timer = $Timer
@onready var status = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer2/status
@onready var timer_label = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer/time
@onready var revise_text = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/revise
@onready var chilling_text = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/chilling

#how much time increases per second when revising
var revising_add_amount := 1
#how much time decreases per second when revising
var chilling_decrease_amount := 1
var seconds_passed = 0

func _ready() -> void:
	change_state(state.paused)
	revise_text.text = str(revising_add_amount)
	chilling_text.text = str(chilling_decrease_amount)


func _process(_delta: float) -> void:
	match current_state:
		state.revising:
			if timer.is_stopped():
				timer.start()
		state.chilling:
			if timer.is_stopped():
				timer.start()


func _on_timer_timeout() -> void:
	match current_state:
		state.revising:
			change_time(revising_add_amount)
			timer.start()
		state.chilling:
			if seconds_passed - chilling_decrease_amount <= 0:
				change_time(seconds_passed * -1)
				play_noise()
				change_state(state.paused)
			else:
				change_time(chilling_decrease_amount * -1)
				timer.start()

func change_time(amount : int):
	seconds_passed += amount
	timer_label.text = convert_seconds_to_time(seconds_passed)

func play_noise():
	$AudioStreamPlayer.play()

func convert_seconds_to_time(full_seconds: int) -> String:
	var hours = full_seconds / 3600
	var minutes = (full_seconds % 3600) / 60
	var seconds = full_seconds % 60
	
	return "%02d:%02d:%02d" % [hours, minutes, seconds]


func _on_revising_pressed() -> void:
	change_state(state.revising)




func _on_paused_pressed() -> void:
	change_state(state.paused)



func _on_chilling_pressed() -> void:
	change_state(state.chilling)

func change_state(new_state : state):
	current_state = new_state
	match current_state:
		state.chilling:
			status.text = "currently: chilling"
		state.revising:
			status.text = "currently: revising"
		state.paused:
			status.text = "currently: paused"


func _on_revise_text_changed(new_text: String) -> void:
	if new_text.is_valid_int() and int(new_text) > 0:
		revising_add_amount = int(new_text)


func _on_chilling_text_changed(new_text: String) -> void:
	if new_text.is_valid_int() and int(new_text) > 0:
		chilling_decrease_amount = int(new_text)


func _on_button_pressed() -> void:
	change_time(seconds_passed * -1)
	print("reset!")


func _on_set_time_pressed () -> void:
	var hours : String = $PanelContainer2/MarginContainer/VBoxContainer/HBoxContainer/hours.text
	var minutes : String = $PanelContainer2/MarginContainer/VBoxContainer/HBoxContainer2/minutes.text
	var seconds : String = $PanelContainer2/MarginContainer/VBoxContainer/HBoxContainer3/seconds.text
	for time : String in [hours, minutes, seconds]:
		if time.is_valid_int() and int(time) >= 0:
			print("Correct")
			continue
		else:
			print("WRONG", time)
			return
	
	if int(minutes) < 60 and int(seconds) < 60:
		timer_label.text = "%02d:%02d:%02d" % [int(hours), int(minutes), int(seconds)]
	
	var new_seconds = (int(hours) * 3600) + (int(minutes) * 60) + int(seconds)
	seconds_passed = new_seconds
	

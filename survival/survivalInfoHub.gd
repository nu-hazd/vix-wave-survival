extends Control
class_name WaveInfoUI

var displayedHour: int = -1

func updateClock(nightNumber : int, currentTime: float, maxTime: float) -> void:
	var progress := clampf(currentTime / maxTime, 0.0, 1.0)
	var hour := int(floor(progress * 6.0))
	if hour == displayedHour:
		return
	displayedHour = hour
	if hour == 0:
		$CenterContainer/VBoxContainer/time.text = "Night %s: 12 AM" % [nightNumber+1]
	else:
		$CenterContainer/VBoxContainer/time.text = "Night %s: %sAM" % [nightNumber+1,hour]
func updateWave(cur : int, maxWave : int) -> void:
	$CenterContainer/VBoxContainer/wave.text = "Wave: %s / %s " % [cur+1,maxWave]

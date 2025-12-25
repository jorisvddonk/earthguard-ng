extends RichTextLabel

var logs = []

func _init():
	GlobalSignals.debuglog.connect(debuglog)
	
func debuglog(text):
	#printt(self.get_v_scroll_bar().value, self.get_v_scroll_bar().min_value, self.get_v_scroll_bar().max_value)
	var t = "[%d] %s" % [Engine.get_frames_drawn(), text]
	printt(t)
	logs.push_back(t)
	if len(logs) > 1000:
		logs.pop_front()
	self.text = "\n".join(logs)
	#self.scroll_to_line(99999)

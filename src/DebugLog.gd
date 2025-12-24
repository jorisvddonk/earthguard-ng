extends RichTextLabel

var logs = []

func _init():
	GlobalSignals.debuglog.connect(debuglog)
	
func debuglog(text):
	#printt(self.get_v_scroll_bar().value, self.get_v_scroll_bar().min_value, self.get_v_scroll_bar().max_value)
	logs.push_back(text)
	if len(logs) > 1000:
		logs.pop_front()
	self.text = "\n".join(logs)
	#self.scroll_to_line(99999)

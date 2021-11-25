extends TextureRect

func bg_change(path: String):
	if path == '':
		texture = null
	else:
		var bg_path = vn.BG_DIR + path
		texture = load(bg_path)

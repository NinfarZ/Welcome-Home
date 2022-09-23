extends StaticBody


#get key
func interact():
	get_tree().call_group("interact", "addKey")
	queue_free()

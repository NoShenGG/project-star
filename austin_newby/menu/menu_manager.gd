extends Node

# Singleton where menus subscribe and get forcibly closed.
# Some menus may listen, and when no menu is selected during exiting, they will forcibly open

var menus : Dictionary[String, Menu] #idk how i feel about this prb should just be array

func force_close():
	for n in menus.values():
		if n.is_open: n.close()

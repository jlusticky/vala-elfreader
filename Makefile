cursesdemo: cursesdemo.vala
	valac -g --pkg gio-2.0 --pkg curses -X -lncurses cursesdemo.vala 

clean:
	rm cursesdemo

.PHONY: clean

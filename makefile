default: server

install: 
	sudo apt install python3
	sudo apt install libluajit-5.1-2
	sudo apt install luarocks
	sudo luarocks install luastatic

build: 
	sudo luastatic mergesort.lua /usr/lib/x86_64-linux-gnu/libluajit-5.1.a -I /usr/include/luajit-2.1/ -no-pie
	mv mergesort.luastatic.c mergesort.c
	rm -f mergesort

clean:
	rm -f mergesort.c

server:
	python3 -m http.server

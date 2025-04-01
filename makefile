install: 
	wget https://www.lua.org/ftp/lua-5.4.7.tar.gz
	tar -xvzf lua-5.4.7.tar.gz
	rm -rf lua-5.4.7.tar.gz
	cd lua-5.4.7/src/; cp Makefile Makefile.gcc; cp Makefile.emcc; sed -i 's/gcc/emcc/g' Makefile.emcc;
	git clone https://github.com/ers35/luastatic.git

uninstall:
	rm -rf luastatic/
	rm -rf lua-5.4.7.tar.gz

build: 
	cd lua-5.4.7/src/; cp Makefile.gcc Makefile; make
	CC="" ./lua-5.4.7/src/lua luastatic/luastatic.lua mergesort.lua
	cd lua-5.4.7/src/; make clean
	cd lua-5.4.7/src/; cp Makefile.emcc Makefile; make
	emcc mergesort.luastatic.c -Ilua-5.4.7/src/ -llua -Llua-5.4.7/src/ -o emscripten5.4.html
	cd lua-5.4.7/src/; make clean

clean:
	cd lua-5.4.7/src/; make clean
	rm -f mergesort.luastatic.c
	rm -f emscripten5.4.html
	rm -f emscripten5.4.js
	rm -f emscripten5.4.wasm

server:
	python3 -m http.server

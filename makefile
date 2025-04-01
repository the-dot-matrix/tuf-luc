SHELL := /bin/bash
lsver = 0.0.12
emver = 4.0.6
default: server

lua-5.4.7.tar.gz:
	wget https://www.lua.org/ftp/lua-5.4.7.tar.gz
lua-5.4.7/: lua-5.4.7.tar.gz
	tar -xvzf lua-5.4.7.tar.gz
	cd lua-5.4.7/src/; cp Makefile Makefile.orig;
lua-5.4.7/Makefile.gcc: lua-5.4.7/
	cd lua-5.4.7/src/; cp Makefile.orig Makefile.gcc;
lua-5.4.7/Makefile.emcc: lua-5.4.7/
	cd lua-5.4.7/src/; cp Makefile.orig Makefile.emcc; sed -i 's/gcc/emcc/g' Makefile.emcc;

luastatic-$(lsver).tar.gz:
	wget https://github.com/ers35/luastatic/archive/refs/tags/$(lsver).tar.gz -O luastatic-$(lsver).tar.gz
luastatic-$(lsver)/: luastatic-$(lsver).tar.gz
	tar -xvzf luastatic-$(lsver).tar.gz

$(emver).tar.gz:
	wget https://github.com/emscripten-core/emsdk/archive/refs/tags/$(emver).tar.gz -O emsdk-$(emver).tar.gz
emsdk-$(emver)/: $(emver).tar.gz
	tar -xvzf emsdk-$(emver).tar.gz
emsdk-$(emver)/upstream/: emsdk-$(emver)/
	cd emsdk-$(emver)/; ./emsdk install latest; ./emsdk activate latest;

uninstall:
	rm -rf lua-5.4.7/
	rm -f lua-5.4.7.tar.gz
	rm -rf luastatic-$(lsver)/
	rm -f luastatic-$(lsver).tar.gz
	rm -rf emsdk-$(emver)/
	rm -f emsdk-$(emver).tar.gz

luagcc: lua-5.4.7/Makefile.gcc
luastatic: luastatic-$(lsver)/
luaemcc: lua-5.4.7/Makefile.emcc
emsdk: emsdk-$(emver)/upstream/

mergesort.luastatic.c: luagcc luastatic
	cd lua-5.4.7/src/; make clean
	cd lua-5.4.7/src/; cp Makefile.gcc Makefile; make
	CC="" ./lua-5.4.7/src/lua luastatic-$(lsver)/luastatic.lua mergesort.lua
emscripten5.4.html: luaemcc mergesort.luastatic.c
	cd emsdk-$(emver)/; source ./emsdk_env.sh
	cd lua-5.4.7/src/; make clean
	cd lua-5.4.7/src/; cp Makefile.emcc Makefile; make
	emcc mergesort.luastatic.c -Ilua-5.4.7/src/ -llua -Llua-5.4.7/src/ -o emscripten5.4.html

clean:
	rm -f mergesort.luastatic.c
	rm -f emscripten5.4.html emscripten5.4.js emscripten5.4.wasm

build: emscripten5.4.html
server: build
	python3 -m http.server

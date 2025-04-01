SHELL := /bin/bash
lua5.4 = lua-5.4.7
lsv = 0.0.12
emv = 4.0.6
default: server

$(lua5.4).tar.gz:
	wget https://www.lua.org/ftp/$(lua5.4).tar.gz
$(lua5.4)/: $(lua5.4).tar.gz
	tar -xvzf $(lua5.4).tar.gz
	cd $(lua5.4)/src/; cp Makefile Makefile.orig;
$(lua5.4)/Makefile.gcc: $(lua5.4)/
	cd $(lua5.4)/src/; cp Makefile.orig Makefile.gcc;
$(lua5.4)/Makefile.emcc: $(lua5.4)/
	cd $(lua5.4)/src/; cp Makefile.orig Makefile.emcc; sed -i 's/gcc/emcc/g' Makefile.emcc;
$(lua5.4): $(lua5.4)/Makefile.gcc $(lua5.4)/Makefile.emcc

luastatic-$(lsv).tar.gz:
	wget https://github.com/ers35/luastatic/archive/refs/tags/$(lsv).tar.gz -O luastatic-$(lsv).tar.gz
luastatic-$(lsv)/: luastatic-$(lsv).tar.gz
	tar -xvzf luastatic-$(lsv).tar.gz
luastatic: luastatic-$(lsv)/

$(emv).tar.gz:
	wget https://github.com/emscripten-core/emsdk/archive/refs/tags/$(emv).tar.gz -O emsdk-$(emv).tar.gz
emsdk-$(emv)/: $(emv).tar.gz
	tar -xvzf emsdk-$(emv).tar.gz
emsdk-$(emv)/upstream/: emsdk-$(emv)/
	cd emsdk-$(emv)/; ./emsdk install latest; ./emsdk activate latest;
emsdk: emsdk-$(emv)/upstream/

install: $(lua5.4) luastatic emsdk
uninstall:
	rm -rf $(lua5.4)/
	rm -f $(lua5.4).tar.gz
	rm -rf luastatic-$(lsv)/
	rm -f luastatic-$(lsv).tar.gz
	rm -rf emsdk-$(emv)/
	rm -f emsdk-$(emv).tar.gz

test/mergesort.luastatic.c:
	cd $(lua5.4)/src/; make clean
	cd $(lua5.4)/src/; cp Makefile.gcc Makefile; make
	CC="" ./$(lua5.4)/src/lua luastatic-$(lsv)/luastatic.lua src/mergesort.lua
	mv mergesort.luastatic.c test/

web/emsdk$(emv)+$(lua5.4).html: test/mergesort.luastatic.c
	cd emsdk-$(emv)/; source ./emsdk_env.sh
	cd $(lua5.4)/src/; make clean
	cd $(lua5.4)/src/; cp Makefile.emcc Makefile; make
	emcc test/mergesort.luastatic.c -I$(lua5.4)/src/ -llua -L$(lua5.4)/src/ -o web/emsdk$(emv)+$(lua5.4).html

clean:
	rm -f test/mergesort.luastatic.c
	rm -f web/emsdk$(emv)+$(lua5.4).html web/emsdk$(emv)+$(lua5.4).js web/emsdk$(emv)+$(lua5.4).wasm

build: web/emsdk$(emv)+$(lua5.4).html
server: build
	python3 -m http.server --directory web

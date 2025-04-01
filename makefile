SHELL := /bin/bash
plat 	= linux
lua5.1 	= lua-5.1.5
lua5.4 	= lua-5.4.7
ljv 	= 2.1.ROLLING
lsv 	= 0.0.12
emv 	= 4.0.6
art = archive/refs/tags/
lj 		= LuaJIT-$(ljv)
ljurl 	= https://github.com/LuaJIT/LuaJIT/
ls 		= luastatic-$(lsv)
lsurl 	= https://github.com/ers35/luastatic/
em 		= emsdk-$(emv)
emurl 	= https://github.com/emscripten-core/emsdk/
t = mergesort
default: server

$(lua5.1).tar.gz:
	wget https://www.lua.org/ftp/$(lua5.1).tar.gz
$(lua5.1)/: $(lua5.1).tar.gz
	tar -xvzf $(lua5.1).tar.gz
	cd $(lua5.1)/src/; \
		sed -i 's/PLAT= none/PLAT= $(plat)/g' Makefile; \
		sed -i 's/-lreadline/ /g' Makefile; \
		sed -i 's/-lhistory/ /g' Makefile; \
		sed -i 's/-lncurses/ /g' Makefile; \
		sed -i 's/lua_readline(L, b, prmt)/0/g' lua.c; \
		sed -i 's/#define LUA_USE_READLINE/ /g' luaconf.h; \
		cp Makefile Makefile.orig;
$(lua5.1)/Makefile.gcc: $(lua5.1)/
	cd $(lua5.1)/src/; cp Makefile.orig Makefile.gcc;
$(lua5.1)/Makefile.emcc: $(lua5.1)/
	cd $(lua5.1)/src/; \
		cp Makefile.orig Makefile.emcc; \
		sed -i 's/gcc/emcc/g' Makefile.emcc;
lua5.1: $(lua5.1)/Makefile.gcc $(lua5.1)/Makefile.emcc

$(lua5.4).tar.gz:
	wget https://www.lua.org/ftp/$(lua5.4).tar.gz
$(lua5.4)/: $(lua5.4).tar.gz
	tar -xvzf $(lua5.4).tar.gz
	cd $(lua5.4)/src/; cp Makefile Makefile.orig;
$(lua5.4)/Makefile.gcc: $(lua5.4)/
	cd $(lua5.4)/src/; cp Makefile.orig Makefile.gcc;
$(lua5.4)/Makefile.emcc: $(lua5.4)/
	cd $(lua5.4)/src/; \
		cp Makefile.orig Makefile.emcc; \
		sed -i 's/gcc/emcc/g' Makefile.emcc;
lua5.4: $(lua5.4)/Makefile.gcc $(lua5.4)/Makefile.emcc

$(lj).tar.gz:
	wget $(ljurl)$(art)v$(ljv).tar.gz -O $(lj).tar.gz
$(lj)/: $(lj).tar.gz
	tar -xvzf $(lj).tar.gz
luajit: $(lj)/
	cd $(lj)/; make;

$(ls).tar.gz:
	wget $(lsurl)$(art)$(lsv).tar.gz -O $(ls).tar.gz
$(ls)/: $(ls).tar.gz
	tar -xvzf $(ls).tar.gz
luastatic: $(ls)/

$(emv).tar.gz:
	wget $(emurl)$(art)$(emv).tar.gz -O $(em).tar.gz
$(em)/: $(emv).tar.gz
	tar -xvzf $(em).tar.gz
$(em)/upstream/: $(em)/
	cd $(em)/; \
		./emsdk install latest; \
		./emsdk activate latest;
emsdk: $(em)/upstream/

install: lua5.1 lua5.4 luajit luastatic emsdk
uninstall:
	rm -rf $(lua5.1)/
	rm -f $(lua5.1).tar.gz
	rm -rf $(lua5.4)/
	rm -f $(lua5.4).tar.gz
	rm -rf $(lj)/
	rm -f $(lj).tar.gz
	rm -rf $(ls)/
	rm -f $(ls).tar.gz
	rm -rf $(em)/
	rm -f $(em).tar.gz

test/$(t)+$(lua5.1).c:
	cd $(lua5.1)/src/; make clean
	cd $(lua5.1)/src/; cp Makefile.gcc Makefile; make
	./$(lua5.1)/src/lua $(ls)/luastatic.lua src/$(t).lua \
		$(lua5.1)/src/liblua.a -I$(lua5.1)/src/
	mv $(t).luastatic.c test/$(t)+$(lua5.1).c
	mv $(t) test/$(t)+$(lua5.1)
test/$(t)+$(lua5.4).c:
	cd $(lua5.4)/src/; make clean
	cd $(lua5.4)/src/; cp Makefile.gcc Makefile; make
	./$(lua5.4)/src/lua $(ls)/luastatic.lua src/$(t).lua \
		$(lua5.4)/src/liblua.a -I$(lua5.4)/src/
	mv $(t).luastatic.c test/$(t)+$(lua5.4).c
	mv $(t) test/$(t)+$(lua5.4)
test/$(t)+$(lj).c:
	./$(lj)/src/luajit $(ls)/luastatic.lua src/$(t).lua \
		$(lj)/src/libluajit.a -I$(lj)/src/ -no-pie
	mv $(t).luastatic.c test/$(t)+$(lj).c
	mv $(t) test/$(t)+$(lj)

web/emsdk$(emv)+$(lua5.1).html: test/$(t)+$(lua5.1).c
	cd $(em)/; source ./emsdk_env.sh
	cd $(lua5.1)/src/; make clean
	cd $(lua5.1)/src/; cp Makefile.emcc Makefile; make
	emcc test/$(t)+$(lua5.1).c -I$(lua5.1)/src/ \
		-llua -L$(lua5.1)/src/ \
		-o web/emsdk$(emv)+$(lua5.1).html
web/emsdk$(emv)+$(lua5.4).html: test/$(t)+$(lua5.4).c
	cd $(em)/; source ./emsdk_env.sh
	cd $(lua5.4)/src/; make clean
	cd $(lua5.4)/src/; cp Makefile.emcc Makefile; make
	emcc test/$(t)+$(lua5.4).c -I$(lua5.4)/src/ \
		-llua -L$(lua5.4)/src/ \
		-o web/emsdk$(emv)+$(lua5.4).html

build5.1: web/emsdk$(emv)+$(lua5.1).html
build5.4: web/emsdk$(emv)+$(lua5.4).html
buildjit: test/$(t)+$(lj).c
build: build5.1 build5.4 buildjit
clean:
	rm -f test/$(t)+$(lj) test/$(t)+$(lj).c
	rm -f test/$(t)+$(lua5.1).c test/$(t)+$(lua5.1)
	rm -f web/emsdk$(emv)+$(lua5.1).*
	rm -f test/$(t)+$(lua5.4).c test/$(t)+$(lua5.4)
	rm -f web/emsdk$(emv)+$(lua5.4).*

server: build
	python3 -m http.server --directory web

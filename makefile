SHELL := /bin/bash
lua5.1 = lua-5.1.5
plat = linux
lua5.4 = lua-5.4.7
art = archive/refs/tags/
lsv = 0.0.12
ls = luastatic-$(lsv)
lsurl = https://github.com/ers35/luastatic/
emv = 4.0.6
em = emsdk-$(emv)
emurl = https://github.com/emscripten-core/emsdk/
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

install: lua5.1 lua5.4 luastatic emsdk
uninstall:
	rm -rf $(lua5.1)/
	rm -f $(lua5.1).tar.gz
	rm -rf $(lua5.4)/
	rm -f $(lua5.4).tar.gz
	rm -rf $(ls)/
	rm -f $(ls).tar.gz
	rm -rf $(em)/
	rm -f $(em).tar.gz

test/$(t)+$(lua5.1).c:
	cd $(lua5.1)/src/; make clean
	cd $(lua5.1)/src/; cp Makefile.gcc Makefile; make
	./$(lua5.1)/src/lua $(ls)/luastatic.lua src/$(t).lua \
		$(lua5.1)/src/liblua.a -I$(lua5.1)/src/
	#CC="" ./$(lua5.1)/src/lua $(ls)/luastatic.lua src/$(t).lua
	mv $(t).luastatic.c test/$(t)+$(lua5.1).c
	mv $(t) test/$(t)+$(lua5.1)
test/$(t)+$(lua5.4).c:
	cd $(lua5.4)/src/; make clean
	cd $(lua5.4)/src/; cp Makefile.gcc Makefile; make
	./$(lua5.4)/src/lua $(ls)/luastatic.lua src/$(t).lua \
		$(lua5.4)/src/liblua.a -I$(lua5.4)/src/
	#CC="" ./$(lua5.4)/src/lua $(ls)/luastatic.lua src/$(t).lua
	mv $(t).luastatic.c test/$(t)+$(lua5.4).c
	mv $(t) test/$(t)+$(lua5.4)

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

clean:
	rm -f test/$(t)+$(lua5.1).c test/$(t)+$(lua5.1)
	rm -f web/emsdk$(emv)+$(lua5.1).*
	rm -f test/$(t)+$(lua5.4).c test/$(t)+$(lua5.4)
	rm -f web/emsdk$(emv)+$(lua5.4).*

build5.1: web/emsdk$(emv)+$(lua5.1).html
build5.4: web/emsdk$(emv)+$(lua5.4).html
server: build5.1 build5.4
	python3 -m http.server --directory web

.PHONY: kona

default:
	cd clox
	clang -o clox/main clox/main.c clox/chunk.c clox/memory.c clox/debug.c clox/value.c clox/vm.c clox/compiler.c clox/scanner.c
	./clox/main

olddefault:
	lua main.lua

test:
	luajit lox/test.lua

generate:
	lua lox/generateast_tool.lua

printer:
	lua lox/AstPrinter.lua

# Get Kona bootstrapped
prebuild:
	cd LuaJIT; make;


kona:
	luajit -b kona/kona.lua kona/interpreter.obj
	cd kona; luajit concatenater.lua
	clang -o kona/kona kona/kona.c LuaJit/src/libluajit.so kona/interpreter.obj

konaclean:
	rm kona/kona;

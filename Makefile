asm = askname.s
obj = askname.o
bin = askname

main: obj bin
	./$(bin)
all: obj bin
obj:
	as $(asm) -o $(bin)
bin:
	ld $(obj) -o $(bin)

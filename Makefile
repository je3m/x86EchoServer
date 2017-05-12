CC_FLAGS = -masm=intel -m32 -c -O3 
CC = gcc
LD_FLAGS = -m32 -ldl

all: server allcaps.so

server.o: server.s
	$(CC) $(CC_FLAGS) server.s -o server.o

server: server.o
	gcc server.o -m32 -o server $(LD_FLAGS)

allcaps.so: allcaps.c
	gcc -m32 -fPIC allcaps.c -shared -o allcaps.so

clean:
	rm server.o server *.so

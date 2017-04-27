CC_FLAGS = -masm=intel -m32 -c -O3
CC = gcc
LD_FLAGS = -m32

all: server

server.o: server.s
	$(CC) $(CC_FLAGS) server.s -o server.o

server: server.o
	gcc server.o -m32 -o server

clean:
	rm server.o server

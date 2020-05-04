all:  app

CC = gcc
# CFLAGS = -O2 -Wall -I .
CFLAGS = -g -D_REENTRANT -Wall
#-fpermissive
# This flag includes the Pthreads library on a Linux box.
# Others systems will probably require something different.
LIB = -lpthread

app: server.c  rio.c  socketChat.h
	gcc $(CFLAGS) -o ser server.c rio.c $(LIB) 

clean:
	rm -f app


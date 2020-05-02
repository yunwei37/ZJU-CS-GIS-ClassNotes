all:  app data

CC = gcc
# CFLAGS = -O2 -Wall -I .
CFLAGS = -g -D_REENTRANT -fpermissive
#-fpermissive
# This flag includes the Pthreads library on a Linux box.
# Others systems will probably require something different.
LIB = -lpthread

app: server.c  ../rio.c ../message.c ../socketChat.h
	g++ $(CFLAGS) -c server.c ../rio.c ../message.c $(LIB)

data: data.cpp data.h server.o rio.o message.o
	g++ $(CFLAGS) -o ser server.o rio.o message.o data.cpp $(LIB)
	rm -f server.o rio.o message.o

clean:
	rm -f app


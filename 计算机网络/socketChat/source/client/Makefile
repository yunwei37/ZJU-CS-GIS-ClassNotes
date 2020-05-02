all:  app

CC = gcc
# CFLAGS = -O2 -Wall -I .
CFLAGS = -g -D_REENTRANT 
# -fpermissive
# This flag includes the Pthreads library on a Linux box.
# Others systems will probably require something different.
LIB = -lpthread


# If using Redhat 8+ or Fedora, may need to add -L/usr/lib/mysql to link to MySQL. 

app: client.c  ../rio.c ../message.c ../socketChat.h
	gcc $(CFLAGS) -o cli client.c ../rio.c ../message.c $(LIB)

clean:
	rm -f app


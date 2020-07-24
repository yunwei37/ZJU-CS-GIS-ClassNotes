# Makefile for cbook/12-Sorting/programs
# Created by the ExportAll facility
# ***************************************************************

PROGRAMS = \
    testsort \
    findcoin \
    mileage \
    mileage2 

# ***************************************************************
# Parameters to control Makefile operation
# Note that the gccx command script must be defined

CC = gccx
CFLAGS = 

# ***************************************************************
# Entry to bring the package up to date

all: $(PROGRAMS)

# ***************************************************************
# Standard entries to remove files from the directories
#    tidy    -- eliminate unwanted files
#    scratch -- delete derived files in preparation for rebuild

tidy:
	rm -f ,* .,* *~ core a.out graphics.ps

scratch: tidy
	rm -f *.o *.a $(PROGRAMS)

# ***************************************************************
# C compilations

findcoin.o: findcoin.c
	$(CC) $(CFLAGS) -c findcoin.c

mileage.o: mileage.c
	$(CC) $(CFLAGS) -c mileage.c

mileage2.o: mileage2.c
	$(CC) $(CFLAGS) -c mileage2.c

sort.o: sort.c sort.h
	$(CC) $(CFLAGS) -c sort.c

testsort.o: testsort.c sort.h
	$(CC) $(CFLAGS) -c testsort.c


testsort: testsort.o sort.o
	$(CC) $(CFLAGS) -o testsort testsort.o sort.o

findcoin: findcoin.o
	$(CC) $(CFLAGS) -o findcoin findcoin.o

mileage: mileage.o
	$(CC) $(CFLAGS) -o mileage mileage.o

mileage2: mileage2.o
	$(CC) $(CFLAGS) -o mileage2 mileage2.o

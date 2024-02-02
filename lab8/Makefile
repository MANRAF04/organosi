SOURCES=qdbmp.c kmeans.c
TARGET=kmeans
GCC=gcc
CFLAGS=-O3 -g -Wall -std=c99 -Ofast

all: $(SOURCES)
	$(GCC) $(CFLAGS) -o $(TARGET) $(SOURCES)

clean:
	rm -Rf *.o $(TARGET) 	

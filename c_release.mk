CC ?= gcc

OBJS  := alocador.o
MAIN := main

CFLAGS += -Wall -Wextra -Wpedantic -g

all: $(MAIN)

$(MAIN): $(MAIN).c $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

$(MAIN).c: ;

.c.o: 
	$(CC) -c $(CFLAGS) $< -o $@

clean:
	@ $(RM) *.o $(MAIN)

.PHONY: clean


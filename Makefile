CC ?= gcc

OBJS  := alocador.o
MAIN := main

CFLAGS  += -Wall -Wextra -Wpedantic -g
LDFLAGS += -no-pie

all: $(MAIN)

$(MAIN): $(MAIN).c $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

$(MAIN).c: ;

.SUFFIXES:
.SUFFIXES: .s .o
.s.o: 
	$(CC) -c $(CFLAGS) $< -o $@

clean:
	@ $(RM) *.o $(MAIN)

.PHONY: clean

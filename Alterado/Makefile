CC ?= gcc

OBJS := meuAlocador.o
MAIN ?= avalia

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

DUMMY := $(shell mkdir -p obj)

ITER ?= 1000000
QSIZE ?= 5000
WORKERS ?= 8
PROG ?= ./obj/main

all: obj/main obj/spmc

obj/main: build.gpr src/main.adb src/workers.adb src/workers.ads
	gprbuild -P build

obj/result.csv: $(PROG) src/bench.sh
	./src/bench.sh $(ITER) $(QSIZE) $(WORKERS) $(PROG) | tee obj/result.csv

graph: obj/result.png

obj/result.png: src/result.gp obj/result.csv
	gnuplot -p $<

obj/spmc: src/spmc.c
	$(CC) -O3 -Wall -Wextra -Werror -o $@ $^ -lpthread

clean:
	gprclean -P build
	rm -rf obj

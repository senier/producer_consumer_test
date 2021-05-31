ITER ?= 1000000
QSIZE ?= 5000
WORKERS ?= 8

all: obj/main

obj/main: build.gpr src/main.adb src/workers.adb src/workers.ads
	gprbuild -P build

obj/result.csv: obj/main src/bench.sh
	./src/bench.sh $(ITER) $(QSIZE) $(WORKERS) | tee obj/result.csv

graph: obj/result.png

obj/result.png: src/result.gp obj/result.csv
	gnuplot -p $<

clean:
	gprclean -P build
	rm -rf obj

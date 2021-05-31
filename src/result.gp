set datafile separator ','
set xlabel "Workers"
set ylabel "Reqs/s"
set format y "%2.0f"
set terminal png
set output 'obj/result.png'
plot 'obj/result.csv' using 1:3 '%lf,%lf,%lf' with lines

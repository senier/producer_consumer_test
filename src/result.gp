set datafile separator ','
set xlabel "Workers"
set ylabel "Reqs/s"
set format y "%2.0f"
plot 'obj/result.csv' using 1:3 '%lf,%lf,%lf' with lines

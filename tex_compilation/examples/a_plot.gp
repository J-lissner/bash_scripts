#!/usr/bin/gnuplot -persist

set terminal postscript eps size 4.5,5.0 enhanced color font 'Helvetica,40' lw 3

f(x)=x**2

set output "x_squared.eps"
plot f(x) w l title 'nice line'

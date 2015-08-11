#!/bin/bash

nimag=$(grep "IMAGES" INCAR | tail -1 | awk '{print $3}')

for i in $(seq 0 $((nimag+1)) ); do
	num=$(printf "%02d" $i)
	ener=$(grep TOTEN $num/OUTCAR | tail -1 | awk '{print $5}')
	natom=$(grep "ions per type" $num/OUTCAR | tail -1 | awk '{natom=0;for(i=5;i<=NF;i++) natom+=$i; print natom}')
	# echo $natom
	echo $i $ener
done


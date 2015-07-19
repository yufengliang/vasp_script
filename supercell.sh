#!/bin/bash

  [ $# -ne 4 ] && exit

  # input: coord.dat (in crystal coordinate) output: supercell
  fil=$4
  nx=$1; ny=$2; nz=$3
  n=($1 $2 $3)
  # Build Super Cell

  sed -n '1,2p' $fil

  for ((i=3;i<=5;i++)); do
    sed -n "$i p" $fil | awk -v n=${n[i-3]} '{printf(" %16.13f  %16.13f  %16.13f\n", n*$1, n*$2, n*$3)}' 
  done

  natline=6
  str=`sed -n '6p' $fil`
  if [[ "$str" == *[A-Za-z]* ]]; then
    sed -n '6p' $fil
    natline=7
  fi

  # echo $natline

  nat=`sed -n "$natline p" $fil|awk '{sum = 0; for (i=1;i<=NF;i++) sum+=$i; print sum}'`
  sed -n "$natline p" $fil|awk -v n=$((nx*ny*nz)) '{for (i=1;i<=NF;i++) printf("%i  ", n*$i); printf("\n")}'
  
  sed -n "$((natline+1)) p" $fil

  sed -n "$((natline+2)),$((natline+nat+1))p" $fil \
  |awk -v nx=$nx -v ny=$ny -v nz=$nz '{ 
    for (ix = 0; ix < nx; ix++)
      for (iy = 0; iy < ny; iy++)
        for (iz = 0; iz < nz; iz++)
          printf(" %16.13f  %16.13f  %16.13f\n",($1+ix)/nx,($2+iy)/ny,($3+iz)/nz)
  }'


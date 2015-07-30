#!/bin/bash

function kdis {
  cat $input | awk -v k1=$1 -v k2=$2 '
  NR>=2 && NR<=4 {
    for (i=1;i<=3;i++) lat[NR-1, i]=$i
  };
  $1 ~ k1 {
    for (i=2;i<=4;i++) vec1[i-1]=$i
  }
  $1 ~ k2 {
    for (i=2;i<=4;i++) vec2[i-1]=$i
  }
  END {
    for (i=1;i<=3;i++) {
      vec[i]=0
      for (j=1;j<=3;j++)
        vec[i]=(vec2[j]-vec1[j])*lat[j,i]+vec[i]
    }
    print sqrt(vec[1]^2+vec[2]^2+vec[3]^2)
  }
  '
}

kpoints_gen() {

# Read in the standard kpoints generation file (like CUB) and
# generate the KPOINTS for linear band structure calculation

local input=$1    # input file
local nk=$2       # How many k-points do you want in total ?
local kpoints=$3  # output file for KPOINTS in vasp
local kline=$4    # 
  
  if [ $# != 4 ]; then
    echo "usage: $0 kpoints.in #k kpoints.out kline.dat"
    exit
  fi
  
  temp=`mktemp`
  sed '/^ *$/d' $input > $temp
  local LPATH=`sed -n '$p' $temp`
  echo $LPATH
  rm $temp

  local count=0;
  local kp
  for kp in $LPATH; do
    echo $kp
    count=$((count+1))
    if [ $count -gt 1 ]; then
      kdis $kp $lastkp
    fi
    local lastkp=$kp
  done

  if [ $count -lt 1 ]; then
    echo "Need more than 1 k-point. "
    exit
  fi
}

  kpoints_gen $1 $2 $3 $4


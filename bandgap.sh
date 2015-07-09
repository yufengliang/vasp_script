#!/bin/bash

 # Find the fundamental band gap (in eV) from the OUTCAR file

 if [ ! -f OUTCAR ]; then
   echo Cannot find a OUTCAR file.
   exit
 fi

 # occupation cutoff: empty or occupied
 empty_cut=0.01 
 occ_cut=0.3 

 # Find the last iteration
 lr=` awk '/ E-fermi /{LAST=FNR}END{print LAST}' OUTCAR` # last line where E-fermi appears 

 ISPIN=`grep ' ISPIN ' OUTCAR|awk '{print $3}'`

 # Work on the file range from lr to the end: the last block of k-point
 temp=`mktemp`
 sed -n "$lr,$ p" OUTCAR > $temp

 kblock=0
 
 cat $temp | awk \
 -v occ_cut=$occ_cut -v empty_cut=$empty_cut \
 'BEGIN{ 
    kblock = 0; ehomo = -10000.0; elumo = 10000.0
    s = 1;
  }
  $1~/k-point/{
    kblock = 1; kstring = $0; 
    next
  }
  /^ *spin component/{s = $3}
  NF == 0 {kblock = 0; next}
  kblock == 1 && NF == 3 {
    if ($3 > occ_cut && ehomo <= $2) {
      ehomo = $2; kh = kstring; nh = $1
    }
    if ($3 < empty_cut && elumo > $2) {
      elumo = $2; kl = kstring; nl = $1
    }
  }
  END{
    print " HOMO ", ehomo, " eV ", " #band ", nh, kh;
    print " LUMO ", elumo, " eV ", " #band ", nl, kl;
    print " Eg = ", elumo - ehomo, " eV "
  }
 '
 rm $temp

#!/bin/bash

 list=$1 # a list of intended cif files
 cif2cell=~/cif2cell-1.2.7/cif2cell 
 overwrite=$2 # 1 -- overwrite mode, otherwise leave as it is

 while read p; do
   field=`echo $p | awk '{print NF}'`
   elem=`echo $p | awk '{print $1}'`
   fpath=`echo $p | awk '{print $2}'`
   if [ $field -gt 1 ]; then
     echo $elem 
     file=$(basename $fpath)
     if [ "$overwrite" = 1 ]; then 
       wget $fpath
     elif [ ! -f $file ]; then
       wget $fpath
     else
       echo $file already exists !
     fi
     $cif2cell $file -p vasp
     mv POSCAR $elem.POSCAR.vasp
   fi
 done < $list

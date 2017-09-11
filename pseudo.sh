#!/bin/bash

build_pseudo() {

  # Grep the element list
  ELEM=$(grep_elem)
  # Grep the number-of-atom list
  ENUM=$(grep_enum)
  # Split it into an array
  IFS=" "; read -a enum <<< $ENUM

  if [ ! -d $PSEUDO_DIR ]; then
    echo Pseudopotential directory $PSEUDO_DIR does not exist !
    return
  fi

  local count=0
  NELECT_COUNT=0
  for elem in $ELEM; do
    count=$((count+1))
    local pseudo=$PSEUDO_DIR/${elem}${PSEUDO_POSTFIX}
    
    if [ -f $pseudo/POTCAR ]; then 
      echo element $elem x ${enum[count-1]}: POTCAR in ${elem}${PSEUDO_POSTFIX}
      elect=`sed -n '2p' $pseudo/POTCAR`
      NELECT_COUNT=`echo "scale=5;$NELECT_COUNT+$elect*${enum[count-1]}"|bc`

      if [ $count == 1 ]; then
        cp $pseudo/POTCAR POTCAR
      else
        cat $pseudo/POTCAR >> POTCAR
      fi
    else
      echo element $elem: ${elem}${PSEUDO_POSTFIX} not found !
      echo Please list the name of elements in your POSCAR file.
      return
    fi
  done
  echo "POTCAR is completed."
  echo "# electrons of the neutral system is " $NELECT_COUNT
}

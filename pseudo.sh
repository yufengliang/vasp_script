#!bin/bash

function build_pseudo() { 
  ELEM=`sed -n '6p' POSCAR`
  if [ ! -d $PSEUDO_DIR ]; then
    echo Pseudopotential directory $PSEUDO_DIR does not exist !
    exit
  fi

  local count=0
  for elem in $ELEM; do
    count=$((count+1))
    local pseudo=$PSEUDO_DIR/${elem}${PSEUDO_POSTFIX}
    if [ -f $pseudo/POTCAR ]; then 
      echo $elem: POTCAR in ${elem}${PSEUDO_POSTFIX}
      if [ $count == 1 ]; then
        cp $pseudo/POTCAR POTCAR
      else
        cat $pseudo/POTCAR >> POTCAR
      fi
    else
      echo $elem: ${elem}${PSEUDO_POSTFIX} not found !
      exit
    fi
  done
}

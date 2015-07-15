#!/bin/bash

states_incar_gen() {
 
  rm -f INCAR
 
  electronic_incar

  cat >> INCAR << EOF

# States

LPARD       =    .TRUE.
IBAND       =    $TMP_IBAND
NBMOD       =    $TMP_NBMOD
KPUSE       =    $TMP_KPUSE
LSEPB       =    $TMP_LSEPB
LSEPK       =    $TMP_LSEPK

EOF

  clean_incar INCAR

}

run_states() {

  echo $job_separator 
  echo "Job = $job"

  if [ ! -d bands ]; then
    echo "Please run a bands calculation first !"
    return
  fi

  mkdir -p states
  cd states

  shopt -s nocasematch
  if [[ $JOB == *"BANDS"* ]] && [ $BANDS_OK -eq 0 ]; then
    echo "BANDS not completed. Go back to check it !"
    cd ../
    return
  fi
  shopt -u nocasematch

  ln -sf ../bands/POSCAR ./
  ln -sf ../bands/POTCAR ./
  ln -sf ../bands/KPOINTS ./
  ln -sf ../bands/WAVECAR ./

  # Setting states variables
  
  # Introducing band index array IFBAND
  # Indices are related to the "fermi level",
  # which is defined as floor(NELECT / 2)
  local NFBAND=$(echo $IFBAND|awk '{print NF}')
  if [ $NFBAND -gt 0 ]; then
    local NE=$(awk '/NELECT/{print $3; exit}' ../bands/OUTCAR)
    local HOMOBASE=$(echo $NE|awk '{printf "%i", $1/2}')
    local IBAND_ADD=$(echo $IFBAND|awk -v HOMOBASE=$HOMOBASE '{for(i=1;i<=NF;i++)printf "%i ", $i+HOMOBASE}')
    TMP_IBAND="$TMP_IBAND $IBAND_ADD"
  fi
 
  # NBMOD
  if [ ! -z "$NBMOD" ] && [ "$NBMOD" -gt 0 ] ; then
    TMP_NBMOD=""
  fi

  states_incar_gen
 
  # RUN !
  vasp_run
 
  # ISPIN = 1

  if [ $TMP_ISPIN -eq 1 ]; then
    for parchg in PARCHG*; do
      local num=$( echo $parchg|awk 'BEGIN{FS="."}; {print $2}' )
      mv $parchg PARCHG.$num.CHGCAR
    done
    cd ../
    return
  fi
  
  # ISPIN = 2
 
  local chgsplit=$VTSTSCRIPTS/chgsplit.sh
  local chgsum=$VTSTSCRIPTS/chgsumf.pl

  if [ ! -f $chgsplit ]; then
    echo "Cannot find: $chgsplit. Check your variable VTSTSCRIPTS. "
    cd ../
    return
  fi

  if [ ! -f $chgsum ]; then
    echo "Cannot find: $chgsum. Check your variable VTSTSCRIPTS. "
    cd ../
    return
  fi

  for parchg in PARCHG*; do
    $chgsplit $parchg
    local num=$( echo $parchg|awk 'BEGIN{FS="."}; {print $2}' )
    $chgsum cf1 cf2 1.0  1.0
    mv CHGCAR_sum PARCHG_UP.$num.CHGCAR
    $chgsum cf1 cf2 1.0 -1.0
    mv CHGCAR_sum PARCHG_DOWN.$num.CHGCAR
    rm cf1 cf2
  done

  cd ../
    
}
 

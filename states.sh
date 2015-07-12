#!/bin/bash

states_incar_gen() {
  
  cat > INCAR << EOF

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

  mkdir states
  cd states

  if [ $BANDS_OK -eq 0 ]; then
    echo "BANDS not completed. Go back to check it !"
    cd ../
    return
  fi

  ln ../bands/POSCAR ./
  ln ../bands/KPOINTS ./
  ln ../bands/CHGCAR./
  ln ../bands/WAVECAR ./

  # Setting states variables
  
  # Introducing band index array IFBAND
  # Indices are related to the "fermi level",
  # which is defined as floor(NELECT / 2)
  if [ -z "$IFBAND" ]; then
    local NE=`awk '/NELECT/{print $3; exit}' OUTCAR`
    local HOMOBASE='echo "scale=0;$NE/2"|bc'
    IBAND_ADD=`echo $IFBAND|awk -v HOMOBASE=$HOMOBASE '{for(i=1;i<=NF;i++)printf "%i ", $i+HOMOBASE}'`
    IBAND="$IBAND $IBAND_ADD"
  fi
 
  # NBMOD
  if [ -z "$NBMOD" ] && [ "$NBMOD" -gt 0 ] ; then
    TMP_NBMOD=""
  fi

  states_incar_gen
 
  # RUN !
  vasp_run
 
  cd ../
    
}
 

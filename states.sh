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

  if [ $BANDS_OK -eq 0 ]; then
    echo "BANDS not completed. Go back to check it !"
    cd ../
    return
  fi

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
 
  cd ../
    
}
 

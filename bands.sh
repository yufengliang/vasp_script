#!/bin/bash

bands_incar_gen() {

  cat > INCAR << EOF
# Job Control
SYSTEM      =   $posname
ICHARG      =   11
EOF

  electronic_incar

}

run_bands() {

  echo $job_separator 
  echo "Job = $job"
  BANDS_OK=0 

  mkdir -p bands
  cd bands

  # To do or not to do and POSCAR
  shopt -s nocasematch
  if [[ $JOB == *"SCF"* ]]; then
    if [ $SCF_OK -eq 0 ]; then
      echo "SCF not completed. Go back to check it !"
      cd ../
      return
    else
      echo "Obtain CHGCAR and POSCAR from SCF."
      cp -f ../scf/CHGCAR  ./
      ln -sf ../scf/POSCAR ./
    fi
  elif [ -f CHGCAR ]; then 
    echo "Use an existing CHGCAR. Run it at your own risk. "
    echo "Obtain POSCAR as input. "
    ln -sf ../POSCAR ./
  else
    echo "Cannot find a CHGCAR file. "
    cd ../
    return
  fi
  shopt -u nocasematch

  # bands variables
  if [ ! -z "$BANDS_ISMEAR" ]; then
    TMP_ISMEAR=$BANDS_ISMEAR
  fi
  if [ ! -z "$BANDS_SIGMA" ]; then
    TMP_SIGMA=$BANDS_SIGMA
  fi

  # INCAR
  bands_incar_gen

  # KPOINTS
  if [ -z "$BANDS_KPOINTS" ]; then
    TMP_KPOINTS=$KPOINTS
  else
    TMP_KPOINTS=$BANDS_KPOINTS
  fi

    cat > KPOINTS << EOF
$TMP_KPOINTS
EOF

  # POTCAR
  ln -sf ../POTCAR ./

  # RUN !
  vasp_run

  # Check
  hit=`grep "${bands_done_msg}" OUTCAR|wc -l`
  if [ $hit -ge 1 ]; then
    echo "$job done !"
    BANDS_OK=1
  fi

  cd ../

}

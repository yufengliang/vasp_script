#!/bin/bash

scf_incar_gen() {

  cat > INCAR << EOF
# Job Control
SYSTEM      =   $posname
ISTART      =   $ISTART
ICHARG      =   $ICHARG
INIWAV      =   $INIWAV

EOF

  electronic_incar

  clean_incar INCAR

}

run_scf() {
 
  echo $job_separator 
  echo "Job = $job"
  SCF_OK=0
  
  mkdir -p scf
  cd scf

  # POSCAR
  shopt -s nocasematch
  if [[ $JOB == *"RELAX"* ]]; then
    if  [ $RELAX_OK -eq 0 ]; then
      echo "Relaxation not completed. SCF aborted !"
      cd ../
      return
    else
      echo "Obtain POSCAR from CONTCAR after relaxation."
      cp -pf ../relax/CONTCAR ./POSCAR
    fi
  else
    echo "Obtain POSCAR as input. "
    ln -sf ../POSCAR ./
  fi
  shopt -u nocasematch

  # default: starting from scratch
  ISTART=0
  ICHARG=2
  INIWAV=0

  # INCAR
  # from scratch
  if [ "${job:0:1}" == "S" ]; then
    echo "Run $job from scratch."
  # restart
  else
    echo "Run $job from an interrupted run."
    if [ -f OUTCAR ]; then
      hit=`grep "${scf_done_msg}" OUTCAR|wc -l`
      if [ $hit -ge 1 ]; then
        echo "$job done !"
        SCF_OK=1
        cd ../
        return
      else 
        echo "Continue $job from last checkpoint. "
        ISTART=1
        ICHARG=1
        INIWAV=1
      fi
    else
      echo "Cannot find OUTCAR. Start from scratch."
    fi
  fi

  # INCAR
  scf_incar_gen  

  # KPOINTS
  if [ -z $SCF_KPOINTS ]; then
    TMP_KPOINTS=$KPOINTS
  else
    TMP_KPOINTS=$SCF_KPOINTS
  fi

    cat > KPOINTS << EOF
$TMP_KPOINTS
EOF

  # POTCAR
  ln -sf ../POTCAR ./

  # RUN !
  vasp_run

  # Check
  hit=`grep "${scf_done_msg}" OUTCAR|wc -l`
  if [ $hit -ge 1 ]; then
    echo "$job done !"
    SCF_OK=1
  fi

  cd ../

}

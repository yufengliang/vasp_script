#!/bin/bash

relax_incar_gen() {

  cat > INCAR << EOF
# Job Control
SYSTEM      =   $posname
ISTART      =   $ISTART
ICHARG      =   $ICHARG
INIWAV      =   $INIWAV

EOF

  electronic_incar

  # Update reset_variables when you edit this
  cat >> INCAR << EOF
# Ionic Relaxation

IBRION      =   $TMP_IBRION
EDIFFG      =   $TMP_EDIFFG
ISIF        =   $TMP_ISIF
ISYM        =   $TMP_ISYM
NSW         =   $TMP_NSW

EOF

  clean_incar INCAR

}

run_relax() {

  echo $job_separator
  echo "Job = $job"
  RELAX_OK=0

  mkdir -p relax
  cd relax

  # default: starting from scratch
  ISTART=0
  ICHARG=2
  INIWAV=1

  # POSCAR and INCAR
  shopt -u nocasematch # Yes, case matters here
  # from scratch
  if [ "${job:0:1}" == "R" ]; then
    echo "Run $job from scratch."
    cp ../POSCAR ./
    rm -f OUTCAR* CONTCAR* WAVECAR* CHGCAR*
  # restart
  else
    local lnum=$(get_file_largest_index OUTCAR)
    echo "Run $job from last checkpoint."
    # If you have an OUTCAR
    if [ -f OUTCAR ]; then
      hit=`grep "${relax_done_msg}" OUTCAR|wc -l`
      if [ $hit -ge 1 ]; then
        echo "$job done !"
        RELAX_OK=1
        cd ../
        return
      # Make sure CONTCAR exist and is something
      elif [ -f CONTCAR ] && [ -s CONTCAR ]; then
        echo "Continue $job from CONTCAR."
        ISTART=1
        ICHARG=1
        INIWAV=1
        # continue to relax
        cp CONTCAR POSCAR
        backup CONTCAR
        backup XDATCAR
        backup OSZICAR
      else
        echo "Cannot find a valid CONTCAR. Start from scratch."
        cp ../POSCAR ./
      fi
      backup OUTCAR
    else
      echo "Cannot find OUTCAR. Start from scratch."
      cp ../POSCAR ./
    fi
  fi

  # INCAR
  relax_incar_gen

  # KPOINTS
  if [ -z $RELAX_KPOINTS ]; then
    TMP_KPOINTS=$KPOINTS
  else
    TMP_KPOINTS=$RELAX_KPOINTS
  fi

    cat > KPOINTS << EOF
$TMP_KPOINTS
EOF

  # POTCAR
  ln -sf ../POTCAR ./

  # RUN !
  vasp_run

  # Check
  hit=`grep "${relax_done_msg}" OUTCAR|wc -l`
  if [ $hit -ge 1 ]; then
    echo "$job done !"
    RELAX_OK=1
  fi

  cd ../
}

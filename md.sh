#!/bin/bash

md_incar_gen() {

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
# Molecular Dynamics

IBRION      =   0

TEBEG       =   $TMP_TEBEG
TEEND       =   $TMP_TEEND

SMASS       =   $TMP_SMASS
POTIM       =   $TMP_POTIM

ISYM        =   0
NSW         =   $TMP_NSW
ISIF        =   $TMP_ISIF

EOF

  clean_incar INCAR

}

run_md() {

  echo $job_separator
  echo "Job = $job"
  MD_OK=0

  mkdir -p md
  cd md

  # default: starting from scratch
  ISTART=0
  ICHARG=2
  INIWAV=0

  # POSCAR and INCAR
  shopt -u nocasematch # Yes, case matters here
  # from scratch
  if [ "${job:0:1}" == "M" ]; then
    echo "Run $job from scratch."
    cp ../POSCAR ./
    rm -f OUTCAR* CONTCAR* WAVECAR* CHGCAR*
  # restart
  else
    local lnum=$(get_file_largest_index OUTCAR)
    echo "Run $job from last checkpoint."
    if [ -f OUTCAR ]; then
      hit=`grep "${md_done_msg}" OUTCAR|wc -l`
      if [ $hit -ge 1 ]; then
        echo "$job done !"
        MD_OK=1
        cd ../
        return
      # Make sure CONTCAR exist and is something
      elif [ -f CONTCAR ]; then
        echo "Continue $job from CONTCAR."
        ISTART=1
        ICHARG=1
        INIWAV=1
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

  # MD Variables
  TMP_ISIF=
  TMP_LREAL=A
  TMP_NELMIN=4
  TMP_ALGO="Very Fast"
  [ -z $MD_ISMEAR ] || TMP_ISMEAR=$MD_ISMEAR
  [ -z $MD_SIGMA ] || TMP_SIGMA=$MD_SIGMA

  # INCAR
  md_incar_gen

  # KPOINTS
  if [ -z $MD_KPOINTS ]; then
    TMP_KPOINTS=$KPOINTS
  else
    TMP_KPOINTS=$MD_KPOINTS
  fi

    cat > KPOINTS << EOF
$TMP_KPOINTS
EOF

  # POTCAR
  ln -sf ../POTCAR ./

  # RUN !
  vasp_run

  # Check
  hit=`grep "${md_done_msg}" OUTCAR|wc -l`
  if [ $hit -ge 1 ]; then
    echo "$job done !"
    MD_OK=1
  fi

  cd ../
}

#!/bin/bash

# messages and texts
relax_done_msg="reached required accuracy - stopping structural energy minimisation"
md_done_msg="what is this ?"
scf_done_msg="aborting loop because EDIFF is reached"
bands_done_msg="aborting loop because EDIFF is reached"
file_separator="======================================================================"
job_separator="----------------------------------------------------------------------"

# 
U_LIST=$SCRIPT_ROOT/u_list.dat

clean_incar() {
# Delete/Comment out the empty assignment
 local incar=$1
 # if RHS of = is empty and the line does not begin with "!", then comment the line
 awk '/= *$/ && !/^!/ {print "!", $0; next} 1' $incar > $$
 cp $$ $incar
 rm $$
}

reset_variables() {

# Electronic Relaxation

# TMP_NELECT
if [ -z $EXTRA_ELECT ]; then
EXTRA_ELECT=0.0
fi

if [ -z $NELECT ]; then
TMP_NELECT=`echo "scale=5; $NELECT_COUNT+$EXTRA_ELECT"|bc`
else
TMP_NELECT=`echo "scale=5; $NELECT+$EXTRA_ELECT"|bc`
fi

TMP_PREC=$PREC
TMP_ENCUT=$ENCUT
TMP_ISMEAR=$ISMEAR
TMP_SIGMA=$SIGMA
TMP_LASPH=$LASPH
TMP_IVDW=$IVDW
TMP_LREAL=$LREAL
TMP_ALGO=$ALGO
TMP_MAXMIX=$MAXMIX
TMP_NCORE=$NCORE
TMP_NPAR=$NPAR

# Magnetism

TMP_ISPIN=$ISPIN
TMP_MAGMOM=$MAGMOM

# LDA+U

TMP_LDAU=$LDAU
TMP_LDAUTYPE=$LDAUTYPE
TMP_LDAUU=$LDAUU

# Electronic Relaxation Control

TMP_NELM=$NELM
TMP_NELMIN=$NELMIN
TMP_EDIFF=$EDIFF

# Ionic Relaxation

TMP_IBRION=$IBRION
TMP_EDIFFG=$EDIFFG
TMP_ISIF=$ISIF
TMP_ISYM=$ISYM
TMP_NSW=$NSW

# States

TMP_IBAND=$IBAND
TMP_NBMOD=$NBMOD
TMP_KPUSE=$KPUSE
TMP_LSEPB=$LSEPB
TMP_LSEPK=$LSEPK

# Molecular Dynamics

TMP_TEBEG=$TEBEG
TMP_TEEND=$TEEND
TMP_SMASS=$SMASS
TMP_POTIM=$POTIM

# Print Control

TMP_LCHARG=$LCHARG
TMP_LWAVE=$LWAVE
TMP_LVTOT=$LVTOT
TMP_LORBIT=$LORBIT
TMP_NWRITE=$NWRITE
TMP_NBLOCK=$NBLOCK

# DOSCAR

TMP_EMIN=$EMIN
TMP_EMAX=$EMAX
TMP_NEDOS=$NEDOS

}

electronic_incar() {

  # Generate LDAUU array from u_list.dat automatically
  shopt -s nocasematch
  if [ "$USE_U_LIST" == ".TRUE." ]; then
    TMP_LDAUU=""
    echo $U_LIST
    for elem in $ELEM; do
      local U=$( awk -v elem=$elem '$1~elem{print $2}' $U_LIST )
      [ -z $U ] && U=0.0
      TMP_LDAUU="$TMP_LDAUU $U"
    done
  fi
  shopt -u nocasematch 

  # Update reset_variables when you edit this
  cat >> INCAR << EOF
# Electronic Relaxation

NELECT      =   $TMP_NELECT
PREC        =   $TMP_PREC
ENCUT       =   $TMP_ENCUT
ISMEAR      =   $TMP_ISMEAR
SIGMA       =   $TMP_SIGMA
LASPH       =   $TMP_LASPH
IVDW        =   $TMP_IVDW
LREAL       =   $TMP_LREAL
ALGO        =   $TMP_ALGO
MAXMIX      =   $TMP_MAXMIX
NCORE       =   $TMP_NCORE
NPAR        =   $TMP_NPAR

# Magnetism

ISPIN       =   $TMP_ISPIN
MAGMOM      =   $TMP_MAGMOM

# LDA+U

LDAU        =   $TMP_LDAU
LDAUTYPE    =   $TMP_LDAUTYPE
LDAUU       =   $TMP_LDAUU

# Electronic Relaxation Control

NELM        =   $TMP_NELM
NELMIN      =   $TMP_NELMIN
EDIFF       =   $TMP_EDIFF

# Print Control

LCHARG      =   $TMP_LCHARG
LWAVE       =   $TMP_LWAVE
LVTOT       =   $TMP_LVTOT
LORBIT      =   $TMP_LORBIT
NWRITE      =   $TMP_NWRITE
NBLOCK      =   $TMP_NBLOCK

# DOSCAR

EMIN        =   $TMP_EMIN
EMAX        =   $TMP_EMAX
NEDOS       =   $TMP_NEDOS

EOF

}

function filesize() {
  # Maybe there is a more robust way of doing so
  ls -lh $1|awk '{print $5}'
}

unknown_job() {
  echo "Unknown job $job. Skip it !"
}

# to lowercase
lcase() {
  echo $@|awk '{print tolower($0)}'
}

vasp_run() {
  echo $VASP_PREFIX $VASP "> stdout"
  ljob=$(lcase $job)
  $VASP_PREFIX $VASP > $HOMEDIR/${posname}.${ljob}.stdout
}

function grep_elem() {
  # This might not be robust enough for a more free-style POSCAR file
  sed -n '6p' POSCAR
}

function grep_enum() {
  # This might not be robust enough for a more free-style POSCAR file
  sed -n '7p' POSCAR
}


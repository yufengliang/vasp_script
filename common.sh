#!/bin/bash

relax_done_msg="reached required accuracy - stopping structural energy minimisation"
scf_done_msg="aborting loop because EDIFF is reached"
file_separator="======================================================================"
job_separator="----------------------------------------------------------------------"

function clean_incar() {
# Delete/Comment out the empty assignment
 local incar=$1
 # if RHS of = is empty and the line does not begin with "!", then comment the line
 awk '/= *$/ && !/^!/ {print "!", $0; next} 1' $incar > $$
 cp $$ $incar
 rm $$
}

function reset_variables() {

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

# Magnetism

TMP_ISPIN=$ISPIN

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

# Print Control

if [ -z $LVTOT ]; then
TMP_LVTOT=.FALSE.
else
TMP_LVTOT=$LVTOT
fi

if [ -z $LORBIT ]; then
TMP_LORBIT=.FALSE.
else
TMP_LORBIT=$LORBIT
fi

}

function electronic_incar() {

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

# Magnetism

ISPIN       =   $TMP_ISPIN

# LDA+U

LDAU        =   $TMP_LDAU
LDAUTYPE    =   $TMP_LDAUTYPE
LDAUU       =   $TMP_LDAUU

# Electronic Relaxation Control

NELM        =   $TMP_NELM
NELMIN      =   $TMP_NELMIN
EDIFF       =   $TMP_EDIFF

# Print Control

LVTOT       =   $TMP_LVTOT
LORBIT      =   $TMP_LORBIT
EOF
  
  clean_incar INCAR
}

function filesize() {
  # Maybe there is a more robust way of doing so
  ls -lh $1|awk '{print $5}'
}

function unknown_job() {
  echo "Unknown job $job. Skip it !"
}

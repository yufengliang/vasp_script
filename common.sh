#!/bin/bash

relax_done_msg="reached required accuracy - stopping structural energy minimisation"
scf_done_msg="aborting loop because EDIFF is reached"

function electronic_incar() {
  cat >> INCAR << EOF
# Electronic Relaxation

NELECT      =   $NELECT
PREC        =   $PREC
ENCUT       =   $ENCUT
ISMEAR      =   $ISMEAR
SIGMA       =   $SIGMA
LASPH       =   $LASPH
IVDW        =   $IVDW

# Magnetism

ISPIN       =   $ISPIN

# LDA+U

LDAU        =   $LDAU
LDAUTYPE    =   $LDAUTYPE
LDAUU       =   $LDAUU

# Electronic Relaxation Control

NELM        =   $NELM
NELMIN      =   $NELMIN
EDIFF       =   $EDIFF

EOF
}

function filesize() {
  # Maybe there is a more robust way of doing so
  ls -lh $1|awk '{print $5}'
}

function unknown_job() {
  echo "Unknown job $job. Skip it !"
}

#!bin/bash

function scf_incar_gen() {
  cat > INCAR << EOF
# Job Control
SYSTEM      =   $dir
ISTART      =   $ISTART
ICHARG      =   $ICHARG
INIWAV      =   $INIWAV

EOF

  electronic_incar

}

function run_scf() {
 
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
  INIWAV=1

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

  scf_incar_gen  

  # KPOINTS
  if [ -z $SCF_KPOINTS ]; then
    KPOINTS_=$KPOINTS
  else
    KPOINTS_=$SCF_KPOINTS
  fi

    cat > KPOINTS << EOF
$KPOINTS_
EOF

  # POTCAR
  ln -sf ../POTCAR ./

  # RUN !
  echo $VASP_PREFIX $VASP
  $VASP_PREFIX $VASP || echo vasp is broken

  # Check
  hit=`grep "${scf_done_msg}" OUTCAR|wc -l`
  if [ $hit -ge 1 ]; then
    echo "$job done !"
    SCF_OK=1
  fi

  cd ../


}

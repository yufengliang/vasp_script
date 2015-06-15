#!bin/bash
#  ======================================================================
#  Import and pre-processing
#  ======================================================================

  # Input block
  INPBLK=vasp.in

  # Check the script folder
  if [ -z $SCRIPT_ROOT ]; then
    SCRIPT_ROOT="."
  fi

  # Obtain the current directory
  if [[ -n $PBS_O_WORKDIR ]]; then
        RUNENV=PBS
        HOMEDIR=$PBS_O_WORKDIR
        PPN=`wc -l $PBS_NODEFILE | awk '{print $1}'`
        PREFIX="aprun -n $PPN"
  elif [[ -n $SLURM_SUBMIT_DIR ]]; then
        RUNENV=SLURM
        HOMEDIR=$SLURM_SUBMIT_DIR
        PPN=$SLURM_NPROCS
        PREFIX="mpirun -np $PPN"
  else
        HOMEDIR="./"
        PPN=1
        RUNENV=
        PREFIX=
  fi

  cd $HOMEDIR
  HOMEDIR=`pwd`
  echo You start from the directory $HOMEDIR.

  # Import functional scripts
  . $HOMEDIR/$INPBLK
  . $SCRIPT_ROOT/common.sh
  . $SCRIPT_ROOT/pseudo.sh
  . $SCRIPT_ROOT/relax.sh
  . $SCRIPT_ROOT/scf.sh

#  ======================================================================
#  Run, Forest, Run !
#  ======================================================================

  count=0
  RELAX_OK=0
  SCF_OK=0

  # loop over POSCAR files
  for file in $FILE; do
   if [ -f $file ]; then

     echo Processing $file ...
     dir=`echo $file|awk 'BEGIN{FS="."}; {print $1}'`
     mkdir -p $dir
     cp $file $dir/POSCAR
     cd $dir

     # construct POTCAR
     shopt -s nocasematch
     if [[ "$JOB" == *"RELAX"* ]] || [[ "$JOB" == *"SCF"* ]]; then 
       build_pseudo
     fi
     shopt -u nocasematch

     # loop over the job sequence
     for job in $JOB; do
       shopt -s nocasematch
       case $job in
         "RELAX"      ) run_relax    ;;
         "MD"         ) ;;
         "SCF"        ) run_scf      ;;
         "BAND"       ) ;;
         "DOS"        ) ;; # run_dos   ;;
         "STATE"      ) ;; # run_state ;;
         "GW"         ) ;;
         *            ) unknown_job ;;
       esac
       shopt -u nocasematch
     done

     cd ..
     echo Done processing $file.

   else
     echo Cannot find the poscar file $file. Skit it !
   fi
   count=$((count+1))
  done

  echo Come back to the home directory $HOMEDIR
  cd $HOMEDIR

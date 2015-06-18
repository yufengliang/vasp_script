#!bin/bash

function bands_incar_gen() {
  cat > INCAR << EOF
# Job Control
SYSTEM      =   $dir
ICHARG      =   11
EOF

  electronic_incar

}

function run_bands() {

  echo $job_separator 
  echo "Job = $job"

  mkdir -p bands
  cd bands

  # To do or not to do
  shopt -s nocasematch
  if [[ $JOB == *"SCF"* ]]; then
    if [ $SCF_OK -eq 0 ]; then
      echo "SCF not completed. Go back and check it !"
      return
    else
      echo "Obtain CHGCAR from SCF."
      ln -sf ../scf/CHGCAR  ./
    fi
 else
   echo "Use an existing CHGCAR. Run it at your own risk. "
 fi 

}

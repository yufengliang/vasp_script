#!/bin/bash

run_dos() {

  echo $job_separator 
  echo "Job = $job"

  if [ ! -d bands ]; then
    echo "Please run a bands calculation first !"
    return
  fi

  cd bands

  if [ $BANDS_OK -eq 0 ]; then
    echo "BANDS not completed. Go back to check it !"
    cd ../
    return
  elif [ ! -d $VTSTSCRIPTS ]; then
    echo "Please specify: VTSTSCRIPTS=/your/vtstscripts/path. "
    cd ../
    return
  else
    # Use this temporarily
    $VTSTSCRIPTS/split_dos
  fi

  cd ../
}
 

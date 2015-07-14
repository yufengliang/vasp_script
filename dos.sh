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
  elif [ ! -f $VTSTSCRIPTS/split_dos ]; then
    echo "Cannot find: $VTSTSCRIPTS/split_dos. Check your variable VTSTSCRIPTS. "
    cd ../
    return
  else
    ljob=$(lcase $job)
    # Use this temporarily
    echo $VTSTSCRIPTS/split_dos > $HOMEDIR/${posname}.${ljob}.stdout
    $VTSTSCRIPTS/split_dos > $HOMEDIR/${posname}.${ljob}.stdout
  fi

  cd ../
}
 

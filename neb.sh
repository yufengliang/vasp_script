#!/bin/bash

neb_incar_gen() {

	cat > INCAR << EOF
# Job Control
SYSTEM      =   $posname
ISTART      =   $ISTART
ICHARG      =   $ICHARG
INIWAV      =   $INIWAV

EOF

	electronic_incar

	cat >> INCAR << EOF
# NEB Relaxation

IBRION      =   $TMP_IBRION
EDIFFG      =   $TMP_EDIFFG
ISIF        =   $TMP_ISIF
ISYM        =   $TMP_ISYM
NSW         =   $TMP_NSW
IMAGES      =   $TMP_IMAGES
SPRING      =   $TMP_SPRING

EOF

	clean_incar INCAR

}

run_neb() {

	echo $job_separator
	echo "Job = $job"
	NEB_OK=0

	[ -z $TMP_IMAGES ] && TMP_IMAGES=5

	cd $HOMEDIR
	poscari=$(readlink -f $file) # initial poscar
	cd -
	poscarf=$(dirname $poscari)/$(basename $poscari | sed 's/_i/_f/g') # final poscar: replace i with f

	if [ ! -f $poscarf ]; then
		echo "Cannot find the final POSCAR for neb: $poscarf "
		exit
	fi

	mkdir -p neb
	cd neb

	# Generate images
	perl $VTSTSCRIPTS/nebmake.pl $poscari $poscarf $TMP_IMAGES

	# default: starting from scratch
	ISTART=0
	ICHARG=2
	INIWAV=0

	local i
	for (( i=0; i<=$((TMP_IMAGES+1)); i++ )); do

		local num=$(printf "%02d" $i)
		cd $num
		# POSCAR and INCAR
		shopt -u nocasematch # Yes, case matters here
		# from scratch
		if [ "${job:0:1}" == "N" ]; then
			echo "Run $job from scratch."
 			rm -f OUTCAR* CONTCAR* WAVECAR* CHGCAR*
		# restart
		else
			local lnum=$(get_file_largest_index OUTCAR)
			echo "Run $job-$num from last checkpoint."
			# If you have an OUTCAR
			if [ -f OUTCAR ]; then
				hit=`grep "${neb_done_msg}" OUTCAR|wc -l`
				if [ $hit -ge 1 ]; then
    				echo "$job done !"
				NEB_OK=1
				cd ../
				return
				# Make sure CONTCAR exist and is something
				elif [ -f CONTCAR ] && [ -s CONTCAR ]; then
					echo "Continue $job-$num from CONTCAR."
					ISTART=1
					ICHARG=1
					INIWAV=1
					# continue to neb
					cp CONTCAR POSCAR
					backup CONTCAR
					backup XDATCAR
					backup OSZICAR
				else
					echo "Cannot find a valid CONTCAR. Start from scratch."
	  			fi
	  			backup OUTCAR
			else
	  			echo "Cannot find OUTCAR. Start from scratch."
			fi
		fi

		cd ../

	done

	# INCAR
	neb_incar_gen

	# KPOINTS
	if [ -z $NEB_KPOINTS ]; then
		TMP_KPOINTS=$KPOINTS
	else
		TMP_KPOINTS=$NEB_KPOINTS
	fi

	cat > KPOINTS << EOF
$TMP_KPOINTS
EOF

	# POTCAR
	ln -sf ../POTCAR ./

#	for (( i=0; i<=$((TMP_IMAGES+1)); i++ )); do
#		local num=$(printf "%02d" $i)
#		ln -f INCAR $num/
#		ln -f KPOINTS $num/
#		ln -f POTCAR $num/
#	done

	# RUN !
	vasp_run

	# Check
	hit=`grep "${neb_done_msg}" OUTCAR|wc -l`
	if [ $hit -ge 1 ]; then
		echo "$job done !"
		NEB_OK=1
	fi
	
	cd ../
}


#!/bin/bash

# sum up DOS from vasp

usage1="usage 1, sum up from DOSi to DOSj: $(basename $0) 1 [i] [j]"
usage2="usage 2, sum up from DOSi, DOSj, DOSk, ... : $(basename $0) 2 [i] [j] [k] ..."

# usage 1
if [[ "$1" -eq 1 ]]; then
	if [ $# -eq 3 ]; then
		range=$(for ((i=$2;i<=$3;i++)); do echo $i; done)
		fstr=$2.to.$3
	else
		echo $usage1
		exit
	fi
# usage 2
elif [[ "$1" -eq 2 ]]; then
	if [ $# -ge 2 ]; then
		range=${@:2} # starting from the 2nd argument
	else
		echo $usage2
		exit
	fi
# something else
else
	echo $usage1
	echo $usage2
	exit
fi

startline=3 # I don't want the first two lines

maxNF=0
for r in $range; do
	file=DOS$r
	[ ! -f $file ] && continue
	NF=$(sed -n "$startline p" $file|awk '{print NF}')
	[[ $NF -gt $maxNF ]] && maxNF=$NF
done

# What is the largest number of columns
echo "max #column = $maxNF"

temp1=temp1.dat # accumulator
temp2=temp2.dat # summation operator
count=0

for r in $range; do
	file=DOS$r
	[ ! -f $file ] && continue
	count=$((count+1))
	echo $file
	if [ $count -eq 1 ]; then
		# make sure the accumulator has the maximum number of cols
		sed -n "$startline,$ p" $file | awk -v maxNF=$maxNF '{for (i=1;i<=maxNF;i++) printf "%s ", $i; printf "\n"}' > $temp1
		# the inital energy point on the energy axis
		ener1=$(head -1 $temp1 | awk '{print $1}')
		# define file string fstr for usage 2
		[[ "$1" -eq 2 ]] && fstr=$r
		continue
	fi
	# align the energy axes by matching ener1
	sline=$(awk -v ener1=$ener1 'BEGIN{sline=0}$1==ener1{sline=NR}END{print sline}' $file)
	if [[ "$sline" -eq 0 ]]; then
		echo "cannot align the energy axis of $file ! "
		continue
	fi
	sed -n "$sline,$ p" $file > $temp2
	paste $temp1 $temp2 > $$
	awk -v maxNF=$maxNF '{
		printf "%s ", $1 # energy col
		for (ic = 2; ic <= maxNF; ic ++ )
			printf "%13.8f", $ic+$(ic+maxNF)
		printf "\n"
	}' $$ > $temp1
	[[ "$1" -eq 2 ]] && fstr=$fstr.$r
done

cp $temp1 DOS.SUM.$fstr
rm $temp1
rm $temp2
rm $$

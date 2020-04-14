#!/bin/bash

TESTDIR=./text_generator/
# mode=BASELINE
# mode=LASTROUND
# mode=HYBRID
# mode=SECURE
mode=SBOX

# Execution iterations
WARMUP_TIMES=3
EVAL_TIMES=10

# Save execution time in an array
declare -a time_array
declare -a tt_array
declare -a size_array
b_idx=0
num=0

# for tt in 256 128 64 32; do
for tt in 256; do
	i=0
    e2etime=0
    echo "$(date) # compiling in mode=${mode} TT=${tt}"
    make clean &>/dev/null ; make TT=$tt MODE=$mode &>/dev/null
#    for size in 10MB 100MB 1GB; do
    for size in 100MB; do
    	echo -n > $TESTDIR/test_${mode}_${tt}_${size}_gmem.txt # clean output file

    	echo -n > $TESTDIR/test_${mode}_${tt}_${size}_smem.txt # clean output file
	    # warm up
	    echo "$(date) # warming gbench,sbench with data size ${size}"
	    for idx in `seq 1 ${WARMUP_TIMES}`; do
			./gbench $TESTDIR/pt_${size}.txt >> $TESTDIR/test_${mode}_${tt}_${size}_gmem.txt # global memory
			./sbench $TESTDIR/pt_${size}.txt >> $TESTDIR/test_${mode}_${tt}_${size}_smem.txt # shared memory
	        sleep 0.1
	    done
	    # test
	    echo "$(date) # running gbench,sbench with data size ${size}"
	    for idx in `seq 1 ${EVAL_TIMES}`; do
	        tstart=$(date +%s%N)

	        ./gbench $TESTDIR/pt_${size}.txt >> $TESTDIR/test_${mode}_${tt}_${size}_gmem.txt
			./sbench $TESTDIR/pt_${size}.txt >> $TESTDIR/test_${mode}_${tt}_${size}_smem.txt

	        tend=$((($(date +%s%N) - $tstart)/1000000))
	        e2etime=$(( $tend + $e2etime ))
	        i=$(( $i + 1 ))
	        echo "$(date) # end2end elapsed $tend ms" 

	        sleep 0.1
	    done

	    et=$( echo "scale=3; $e2etime / $i " | bc )
	    echo "${mode} ${tt} ${size}: Average ${et} ms per run"

	    time_array[$b_idx]=${et}
	    tt_array[$b_idx]=${tt}
	    size_array[$b_idx]=${size}
	    b_idx=$((b_idx+1))

	    echo

    done
 #    if [ "$mode" == "BASELINE" ]  || [ "$mode" == "SBOX" ] ; then
	# break
 #    fi
done
num=${b_idx}
b_idx=0
for b in ${time_array[*]}; do
    echo "mode=${mode} tt=${tt_array[${b_idx}]} size=${size_array[${b_idx}]}: Average ${b} ms per run"
    b_idx=$((b_idx+1))
done


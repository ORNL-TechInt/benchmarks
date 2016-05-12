#!/bin/bash


#########################################################################################
# ORNL OLCF-3 plot block I/O single host full run benchmark results script              #
#                                                                                       #
#########################################################################################
# Originally by Sarp Oral <oralhs@ornl.gov>                                             #
# Oak Ridge Leadership Computing Facility                                               #
# National Center for Computational Science                                             #
# Oak Ridge National Laboratory                                                         #
#                                                                                       #
#                                                                                       #
# Sarp Oral <oralhs@ornl.gov>								#
# v2. Fixed indexing bugs in the plotting sections                                      #
#                                                                                       #
# Copyright (C) 2009-2016 UT-Battelle, LLC                                              #
# This source code was developed under contract DE-AC05-00OR22725                       #
# and there is a non-exclusive license for use of this work by or                       #
# on behalf of the US Government.                                                       #
#                                                                                       #
# UT-Battelle, LLC AND THE GOVERNMENT MAKE NO REPRESENTATIONS AND                       #
# DISCLAIM ALL WARRANTIES, BOTH EXPRESSED AND IMPLIED. THERE ARE NO                     #
# EXPRESS OR IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A                     #
# PARTICULAR PURPOSE, OR THAT THE USE OF THE SOFTWARE WILL NOT                          #
# INFRINGE ANY PATENT, COPYRIGHT, TRADEMARK, OR OTHER PROPRIETARY                       #
# RIGHTS, OR THAT THE SOFTWARE WILL ACCOMPLISH THE INTENDED RESULTS                     #
# OR THAT THE SOFTWARE OR ITS USE WILL NOT RESULT IN INJURY OR DAMAGE.                  #
# The user assumes responsibility for all liabilities, penalties, fines,                #
# claims, causes of action, and costs and expenses, caused by, resulting                #
# from or arising out of, in whole or in part the use, storage or disposal              #
# of the SOFTWARE.                                                                      #
#########################################################################################

#################################################################################################################
# NOTICE													#
#################################################################################################################
# This script requires:												#
# 1) A pre-built gnuplot binary ready to execute.								#
# 2) A pre-built ps2pdf binary to convert the gnuplot generated EPS plot files into PDF files			#
#														#
# Usage:													#
# sh ./<this-script> <single-host-full-run-data-file-name(CSV)> <appliancename> <diskname>			#
#														#
# Example:													#
# sh ./plot_blockio_single_host_full_run.sh block_io_single_host_full_run_Oct_01_11_18_52.csv acme-mk1 sas-10k	#
#														#
# Please refer to the README file distributed with this script for further details.				#
#################################################################################################################


#########################################################################################
# OFFEROR, MODIFY BELOW VARIABLES TO FIT TO YOUR TEST SYSTEM                            #
#########################################################################################
# There are no modifiable variables for this script!					#
#########################################################################################
# BEGIN OF MODIFIABLE VARIABLES AND PARAMETERS                                          #
#########################################################################################
#########################################################################################
# END OF MODIFIABLE VARIABLES AND PARAMETERS                                            #
#########################################################################################


#########################################################################
#               W A R N I N G !         W A R N I N G !                 #
#########################################################################
# DO NOT MODIFY ANYTHING BELOW !                                        #
# THERE ARE NO USER MODIFIABLE VARIABLES BELOW  !                       #
# ALL MODIFIABLE VARIABLES ARE LOCATED AT THE BEGINNING OF THIS FILE !  #
#########################################################################


#########################################################################
# DO NOT MODIFY ANYTHING BELOW !                                        #
#########################################################################

die() {
	echo "$@" 1>&2
	exit 1
}

EXPECTED_ARGS=3

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` <data-file-name> <appliance-name> <disk-type>"
  die "Missing arguments! Need a data file name, appliance name, and a disk name!"
fi

temp_file="$1.tmp"
sed '1d' $1 > ${temp_file}


appl=$2
disk=$3

gnuplot=`which gnuplot`

old_IFS=$IFS
IFS=$'\n'
raw_data=($(cat ${temp_file})) # array
IFS=$old_IFS

echo ${#raw_data[@]} "total experiments to be processed" 

index=0
raw_io_mode=()
raw_block_size=()
raw_queue_size=()
raw_device_num=()

for line in ${raw_data[@]}; do
	raw_io_mode[${index}]="$(echo $line | awk 'BEGIN { FS = "," } ; { print $1 }')"
	raw_block_size[${index}]="$(echo $line | awk 'BEGIN { FS = "," } ; { print $2 }')"
	raw_queue_size[${index}]="$(echo $line | awk 'BEGIN { FS = "," } ; { print $3 }')"
	raw_device_num[${index}]="$(echo $line | awk 'BEGIN { FS = "," } ; { print $4 }')"
	let index++
	
done


io_mode=$(for i in ${raw_io_mode[@]}; do echo $i; done | sort | uniq)
block_size=$(for i in ${raw_block_size[@]}; do echo $i; done | sort -n | uniq)
queue_size=$(for i in ${raw_queue_size[@]}; do echo $i; done | sort -n | uniq)
device_num=$(for i in ${raw_device_num[@]}; do echo $i; done | sort -n | uniq)

queue_size_len=0

for queue in ${queue_size}; do
        let queue_size_len++
done

let last_plot_index=queue_size_len



#to set the xtics correctly later on
for b in ${block_size[@]}; do xtics="$xtics,$b"; done; xtics=${xtics#,}

for mode in ${io_mode}; do
	temp_out_file="${mode}_temp.out"
	echo ${temp_out_file}
	[ -e ${temp_out_file} ] && rm ${temp_out_file}
		for block in ${block_size}; do
		outstring="${block}"
			for queue in ${queue_size}; do
				tempstring=$(grep "${mode},${block},${queue}," ${temp_file} | awk 'BEGIN { FS = "," } ; {print $5,$7,$9}')
				outstring="${outstring}	${tempstring}"
				unset tempstring
			done
			echo ${outstring} >> ${temp_out_file}
		done
done

#start rounding for axes

#to set the max scale for seq IO graphs
seq_max=$(grep "seq" ${temp_file} | awk 'BEGIN { FS = ","; max=0 };  {if($5>max) max=$5}; END {print max}'); 
echo "seq_max is $seq_max"
seq_max=${seq_max/\.*}
echo "seq_max is $seq_max"

number=$seq_max

sd=0; nd=0; on=$number 

# use while loop to caclulate the number of digit
while [ $number -gt 0 ]
do
    sd=$(( $number % 10 )) # get Remainder
    number=$(( $number / 10 ))
    nd=$(( $nd + 1)) # calculate all digit in a number till n is not zero
done

let a=nd-2; b=$(echo "$seq_max/(10^$a)" | bc); let b++

seq_max=$(echo "$b*10^$a" | bc)

#to set the max scale for rand IO graphs
rand_max=$(grep "rand" ${temp_file} | awk 'BEGIN { FS = ","; max=0 };  {if($5>max) max=$5}; END {print max}');
echo "rand_max is $rand_max"
rand_max=${rand_max/\.*}
echo "rand_max is $rand_max"

number=$rand_max 

sd=0; nd=0; on=$number

# use while loop to caclulate the number of digit
while [ $number -gt 0 ]
do      
    sd=$(( $number % 10 )) # get Remainder
    number=$(( $number / 10 ))
    nd=$(( $nd + 1)) # calculate all digit in a number till n is not zero
done    
        
let a=nd-2; b=$(echo "$rand_max/(10^$a)" | bc); let b++

rand_max=$(echo "$b*10^$a" | bc)

#done rounding for the axes

title_file_name=${temp_file##.}
title_file_name=${title_file_name%.tmp}
title_file_name=${title_file_name%.csv}

for mode in ${io_mode}; do
	unset plot_command_max
	unset plot_command_first_max
	unset plot_command_last_max
	unset plot_command_regular_max

	unset plot_command_median
	unset plot_command_first_median
	unset plot_command_last_median
	unset plot_command_regular_median

        temp_out_file="${mode}_temp.out"
	temp_plot_max_file="${mode}_max_temp.plot"
	temp_plot_median_file="${mode}_median_temp.plot"
	title_max="${mode}-Max-${title_file_name}-${appl}-${disk}"
	title_median="${mode}-Median-${title_file_name}-${appl}-${disk}"
	gnp_index=1
	for queue in ${queue_size}; do
			first_plot_index=$(($gnp_index*3-1))
			second_plot_index=$(($first_plot_index+1))
			third_plot_index=$(($second_plot_index+1))

			if [ ${gnp_index} -eq "1" ]; then
				plot_command_first_max="plot \"${temp_out_file}\" using 1:${first_plot_index} title \"Max-${queue}\" with linespoints," 
				plot_command_max="${plot_command_max} ${plot_command_first_max}"
			elif [ ${gnp_index} -eq "${last_plot_index}" ]; then
                                plot_command_last_max="\"${temp_out_file}\" using 1:${first_plot_index} title \"Max-${queue}\" with linespoints" 
				plot_command_max="${plot_command_max} ${plot_command_last_max}"
   			else
				plot_command_regular_max="\"${temp_out_file}\" using 1:${first_plot_index} title \"Max-${queue}\" with linespoints,"
				plot_command_max="${plot_command_max} ${plot_command_regular_max}"
			fi


			if [ ${gnp_index} -eq "1" ]; then
                                plot_command_first_median="plot \"${temp_out_file}\" using 1:${second_plot_index}:${third_plot_index} title \"Median-${queue}\" with errorlines,"
                                plot_command_median="${plot_command_median} ${plot_command_first_median}"
                        elif [ ${gnp_index} -eq "${last_plot_index}" ]; then
                                plot_command_last_median="\"${temp_out_file}\" using 1:${second_plot_index}:${third_plot_index} title \"Median-${queue}\" with errorlines"
                                plot_command_median="${plot_command_median} ${plot_command_last_median}"
                        else
                                plot_command_regular_median="\"${temp_out_file}\" using 1:${second_plot_index}:${third_plot_index} title \"Median-${queue}\" with errorlines,"
                                plot_command_median="${plot_command_median} ${plot_command_regular_median}"
                        fi

			let gnp_index++
	done
	
	#echo ${plot_command}	


if [ "${mode}" == "seq_wr" -o "${mode}" == "seq_rd" ]; then
	ymax=${seq_max}
elif [ "${mode}" == "rand_wr" -o "${mode}" == "rand_rd" ]; then
	ymax=${rand_max}
else
	die "no clue"	
fi

echo "starting to generate the plot files"

title_max_temp=$title_max


title_max_temp=`echo $title_max | sed -e 's/_/-/g'`
title_max=$title_max_temp


title_median_temp=$title_median


title_median_temp=`echo $title_median | sed -e 's/_/-/g'`
title_median=$title_median_temp

#For the Max graph
echo "set terminal postscript color eps \"Helvetica\" 11
set output \"${title_max}.eps\" 
set title \"${title_max}\" 
set xlabel \"block size\" 
set ylabel \"MB/s\" 
set key below enhanced autotitles box 
set ticslevel 0 
set xtics (\"4K\" 4096, \"8K\" 8192, \"16K\" 16384, \"32K\" 32768, \"64K\" 65536, \"128K\" 131072, \"256K\" 262144, \"512K\" 524288, \"1M\" 1048576, \"2M\" 2097152, \"4M\" 4194304, \"8M\" 8388608) 
set yrange [10:${ymax}]
set logscale x
${plot_command_max}" >> ${temp_plot_max_file}

echo "done generating the plot file for max"

#For the Median graph with error bars
echo "set terminal postscript color eps \"Helvetica\" 11
set output \"${title_median}.eps\"
set title \"${title_median}\" 
set xlabel \"block size\" 
set ylabel \"MB/s\" 
set key below enhanced autotitles box
set ticslevel 0
set xtics (\"4K\" 4096, \"8K\" 8192, \"16K\" 16384, \"32K\" 32768, \"64K\" 65536, \"128K\" 131072, \"256K\" 262144, \"512K\" 524288, \"1M\" 1048576, \"2M\" 2097152, \"4M\" 4194304, \"8M\" 8388608) 
set yrange [10:${ymax}]
set logscale x
${plot_command_median}" >> ${temp_plot_median_file}

echo "done generating the plot file for median" 


#Plot Max graph
gnuplot < ${temp_plot_max_file}

#Plot Median graph
gnuplot < ${temp_plot_median_file}

echo "done plotting"

done

for mode in ${io_mode}; do
	temp_out_file="${mode}_temp.out"
        temp_plot_max_file="${mode}_max_temp.plot"
        temp_plot_median_file="${mode}_median_temp.plot"

	rm ${temp_out_file}
	rm ${temp_plot_max_file}
	rm ${temp_plot_median_file}
done

rm ${temp_file}

for i in *.eps; do ps2pdf $i; done


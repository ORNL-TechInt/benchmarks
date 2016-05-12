#!/bin/bash

#########################################################################################
# ORNL OLCF-3 obdfilter-survey benchmark configuration and launcher shell script 	#
#                                                                                       #
#########################################################################################
# Originally by Sarp Oral <oralhs@ornl.gov>                                             #
# Oak Ridge Leadership Computing Facility                                               #
# National Center for Computational Science                                             #
# Oak Ridge National Laboratory                                                         #
#                                                                                       #
# Sarp Oral <oralhs@ornl.gov>                                                           #
# v2. Minor bug fixes				                                  	#
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
#                                                                                       #
# Refer to README for more details                                                      #
#											#
# For questions contact Subcontracts Administrator      				#
#########################################################################################


#########################################################################
# BEGINNING OF MODIFIABLE VARIABLES AND PARAMETERS			# 
#########################################################################


# Provide a name representing the test run.
# This name will be used for archiving the result set
archive_name="criusfs-obdfilter-run"

# List ALL OST targets in the system
# Start with the first OSS and linearly add first OSS' OSTs.
# After exhausting the first OSS, move to the second OSS and continue
# adding targets to the list in a linear fashion
# Sytnax: <oss-name>:<ost-name>
# Use below example as a template

#	raw_values=(
#	tick-oss1:testfs-OST0000 tick-oss1:testfs-OST0001 tick-oss1:testfs-OST0002 \
#	tick-oss2:testfs-OST0003 tick-oss2:testfs-OST0004 tick-oss2:testfs-OST0005 \
#	tick-oss3:testfs-OST0006 tick-oss3:testfs-OST0007 tick-oss3:testfs-OST0008 \
#	tick-oss4:testfs-OST0009 tick-oss4:testfs-OST000a tick-oss4:testfs-OST000b)

raw_values=(
       crius-oss1:criusfs-OST0000 crius-oss1:criusfs-OST0006 crius-oss1:criusfs-OST000c crius-oss1:criusfs-OST0012 crius-oss1:criusfs-OST0018 \
       crius-oss1:criusfs-OST001e crius-oss1:criusfs-OST0024 crius-oss1:criusfs-OST002a crius-oss1:criusfs-OST0030 crius-oss1:criusfs-OST0036 \
       crius-oss2:criusfs-OST0001 crius-oss2:criusfs-OST0007 crius-oss2:criusfs-OST000d crius-oss2:criusfs-OST0013 crius-oss2:criusfs-OST0019 \
       crius-oss2:criusfs-OST001f crius-oss2:criusfs-OST0025 crius-oss2:criusfs-OST002b crius-oss2:criusfs-OST0031 crius-oss2:criusfs-OST0037 \
       crius-oss3:criusfs-OST0002 crius-oss3:criusfs-OST0008 crius-oss3:criusfs-OST000e crius-oss3:criusfs-OST0014 crius-oss3:criusfs-OST001a \
       crius-oss3:criusfs-OST0020 crius-oss3:criusfs-OST0026 crius-oss3:criusfs-OST002c crius-oss3:criusfs-OST0032 crius-oss3:criusfs-OST0038 \
       crius-oss4:criusfs-OST0003 crius-oss4:criusfs-OST0009 crius-oss4:criusfs-OST000f crius-oss4:criusfs-OST0015 crius-oss4:criusfs-OST001b \
       crius-oss4:criusfs-OST0021 crius-oss4:criusfs-OST0027 crius-oss4:criusfs-OST002d crius-oss4:criusfs-OST0033 crius-oss4:criusfs-OST0039 \
       crius-oss5:criusfs-OST0004 crius-oss5:criusfs-OST000a crius-oss5:criusfs-OST0010 crius-oss5:criusfs-OST0016 crius-oss5:criusfs-OST001c \
       crius-oss5:criusfs-OST0022 crius-oss5:criusfs-OST0028 crius-oss5:criusfs-OST002e crius-oss5:criusfs-OST0034 crius-oss5:criusfs-OST003a \
       crius-oss6:criusfs-OST0005 crius-oss6:criusfs-OST000b crius-oss6:criusfs-OST0011 crius-oss6:criusfs-OST0017 crius-oss6:criusfs-OST001d \
       crius-oss6:criusfs-OST0023 crius-oss6:criusfs-OST0029 crius-oss6:criusfs-OST002f crius-oss6:criusfs-OST0035 crius-oss6:criusfs-OST003b)

#raw_values=(
#       tick-oss1:testfs-OST0000 tick-oss1:testfs-OST0001 tick-oss1:testfs-OST0002 \
#       tick-oss2:testfs-OST0004 tick-oss2:testfs-OST0005 tick-oss2:testfs-OST0006 \
#       tick-oss3:testfs-OST0008 tick-oss3:testfs-OST0009 tick-oss3:testfs-OST000a)

# Enter the aggregate cache size on RAID controllers (in MBytes)
cache_size=131072 
#cache_size=16384 
#cache_size=2048 

#########################################################################
# END OF MODIFIABLE VARIABLES AND PARAMETERS				#
#########################################################################


#########################################################################
#               W A R N I N G !         W A R N I N G !                 #
#########################################################################
# DO NOT MODIFY ANYTHING BELOW !                                        #
#########################################################################

function log2 {
    local x=0
    for (( y=$1; $y > 0; y >>= 1 )) ; do
        let "x += 1"
    done
    let "x -= 1"
    test $x -lt "0" && let "x = 0"
    echo $x
}

out_base=`pwd`

bin_home="${out_base}"

archive_name="$archive_name-`date +%F-%H-%M`"

test_dir="current_test_dir"
out_home="${out_base}/new_out_destination"
archive_home="${out_base}/completed_sets"


rslt_loc=${rslt_loc:-"${out_home}/default"}
rslt=${rslt:-"$rslt_loc/obdfilter_survey_`date +%F@%R`_`uname -n`"}

# Set this true to check file contents
verify=${verify:-0}

# total size (MBytes) per obd instance
# large enough to avoid cache effects
# and to make test startup/shutdown overhead insignificant
# Calculate this based on the RAID controller cache size and
# number OSTs to be tested.
size=$((cache_size*8/${#raw_values[@]}))

# Check to see if the calculated size is a power of two
# and if not round it up to the closest power of two
z=$(log2 $size)

if [ "$size" -ne "0" -a "$((2**z))" -ne "$size" ]; then
   let "z+= 1"
fi
let "size=2**z"


# record size (KBytes) ( 7168 max)
rsz_str="8 128 1024"


# number of objects per OST
nobj_str="1 4 16"

# threads per OST (1024 max)
thr_str="1 2 4 8 16"

# just to speed up small message iterations
small_size_cap=64
# in MBytes
small_size_default=$((size/4))


# prep the dir structure for testing and output
mkdir -p ${test_dir}
ln -s ${test_dir} ${out_home}
cd ${out_home}

mkdir -p ${#raw_values[@]}-luns; 

export out_home rslt_loc rslt verify size rsz_str nobj_str 
export thr_str small_size_cap small_size_default 

targets=""

index=${#raw_values[@]}

echo -e "timestamp is `date` \n\n"

targets="${raw_values[@]}"; 
echo -e "targets=\"$targets\"\n"; 
	
cd ${out_home}
rm -f default
dir_index=${index}
ln -s ${dir_index}-luns default
cd ${bin_home}
export targets
echo "executing the survey"
sh ${bin_home}/obdfilter-survey-olcf

echo -e "\ntimestamp is `date`\n"

echo -e "\nProcessing results!\n"

# Done running the script.
# Now archive results

cd ${out_base}
rm -f ${out_home}
mkdir -p ${archive_home} 
mv ${test_dir} ${archive_home}/${archive_name}
cd ${archive_home}
rm -f latest
ln -s ${archive_name} latest

echo -e "\nAll Done!\n"

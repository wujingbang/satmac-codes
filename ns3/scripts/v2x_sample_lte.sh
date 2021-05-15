#!/bin/bash

 #/* -*-  Mode: C++; c-file-style: "gnu"; indent-tabs-mode:nil; -*- */
 #
 # NIST-developed software is provided by NIST as a public
 # service. You may use, copy and distribute copies of the software in
 # any medium, provided that you keep intact this entire notice. You
 # may improve, modify and create derivative works of the software or
 # any portion of the software, and you may copy and distribute such
 # modifications or works. Modified works should carry a notice
 # stating that you changed the software and should note the date and
 # nature of any such change. Please explicitly acknowledge the
 # National Institute of Standards and Technology as the source of the
 # software.
 #
 # NIST-developed software is expressly provided "AS IS." NIST MAKES
 # NO WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
 # OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 # WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 # NON-INFRINGEMENT AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR
 # WARRANTS THAT THE OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED
 # OR ERROR-FREE, OR THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT
 # WARRANT OR MAKE ANY REPRESENTATIONS REGARDING THE USE OF THE
 # SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT NOT LIMITED TO THE
 # CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
 #
 # You are solely responsible for determining the appropriateness of
 # using and distributing the software and you assume all risks
 # associated with its use, including but not limited to the risks and
 # costs of program errors, compliance with applicable laws, damage to
 # or loss of data, programs or equipment, and the unavailability or
 # interruption of operation. This software is not intended to be used
 # in any situation where a failure could cause risk of injury or
 # damage to property. The software developed by NIST employees is not
 # subject to copyright protection within the United States.

OVERWRITE=1

SCENARIO="v2x_communication_example_lte"
SIMULATION_TIME=200 #Change to 81 seconds to simulate 1000 sidelink periods of 80 ms

LOG_COL="log_col.txt"
LOG_LPF="log_lpf.txt"
function run_config ()
{
  if [ "$#" -ne 2 ];then
    echo "$#"
    echo "Expects 2 arguments"
    exit
  fi

  if [[ ! -d "scratch" ]];then
    echo "ERROR: $0 must be copied to ns-3 root directory!" 
    exit
  fi

  if [[ ! -e "scratch/$SCENARIO.cc" ]];then
    echo "ERROR: $SCENARIO.cc must be copied to scratch folder!" 
    exit
  fi

  stime=$SIMULATION_TIME #Simulation time in s. Add 1 second to desired simulation time to allow for configuration.
  NODE=$1
  ResKeep=$2

  STARTRUN=1
  MAXRUNS=1

  echo "$NODE"
 
  ver="P${ResKeep}"


#Version for logging run output


    basedir="LTEMODE4/${ver}"


    newdir="results/${basedir}"
    if [[ -d $newdir && $OVERWRITE == "0" ]];then
      echo -e "$newdir exist!\nNO OVERWRITE PERMISSION!"
      continue
    fi
    if [ -d $newdir ];then
      #rm -rf $newdir
      echo 
    else
      mkdir -p $newdir
    fi
    

  arguments="--node=$NODE --time=$SIMULATION_TIME --probResourceKeep=$ResKeep --log_lpf=log_lpf_n$NODE.txt --log_collision=log_collision_n$NODE.txt"


linediv="\n-----------------------------------\n"

  for ((run=$STARTRUN; run<=$MAXRUNS; run++))
  do

    OUTFILE="${newdir}/log_n$NODE.txt"
    rm -f $OUTFILE
    touch $OUTFILE
  
    runinfo="$SCENARIO, RUN: ${ver}_${run}"
    echo -e "\n$runinfo saved to dir: ${newdir}\n"
    run_args="$arguments"
    echo -e "$runinfo, $run_args $linediv" >> $OUTFILE
  
    ./waf --cwd=$newdir --run "$SCENARIO $run_args" >> $OUTFILE 2>&1 &
  done

  wait
  echo "${basedir}_N${NODE} Evaluating traces..."
  pwd
  #bash pscch-error-stats.sh $ver $STARTRUN $MAXRUNS & # PSCCH collisions and subframe overlaps
}

#for resp in 3 20 33; do

LOG=$0.log
main_log_file="./main_${SCENARIO}.log"
echo "Running simulations..."
echo "Simulation process settings are summarized in $LOG"
echo "Execution status is logged in ${main_log_file}"
echo -e "\n============== `date` ============" >> $LOG
echo -e "\n============== `date` ============" >> $main_log_file

# Last 5 arguments (TJAlgo Percent, enableFullDuplex, changeProb, vehiclePercent, #vehicle)

#  NODE=$1
#  EXP_RATIO=$2
#  CUT_RATIO_THS=$3
#  CUT_RATIO_EHS=$4
#  ADJ_ENA=$5
#  ADJ_FRAME_ENA=$6

#  TDMA_ENA=$10
#  BSM_SIZE=$11
#  BSM_INTERVAL=$12

#rm -rf results

run_config 1000 0.5   >> $main_log_file 2>&1 &
run_config 800 0.5   >> $main_log_file 2>&1 &
run_config 600 0.5   >> $main_log_file 2>&1 &
run_config 400 0.5   >> $main_log_file 2>&1 &
run_config 200 0.5   >> $main_log_file 2>&1 &

#run_config 800 0   >> $main_log_file 2>&1 &
#run_config 600 0   >> $main_log_file 2>&1 &
#run_config 400 0   >> $main_log_file 2>&1 &
#run_config 200 0   >> $main_log_file 2>&1 &




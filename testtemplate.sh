#!/bin/bash
# 
# by John Xu
# Template for test scripts
# Version 0.1
#
# --------------------------------------------
# Main routine for performing the test bucket
# --------------------------------------------
 
CALLER=`basename $0`         # The Caller name
SILENT="no"                  # User wants prompts
let "errorCounter = 0"
 
# ----------------------------------
# Handle keyword parameters (flags).
# ----------------------------------
 
# For more sophisticated usage of getopt in Linux, 
# see the samples file: /usr/lib/getopt/parse.bash
 
TEMP=`getopt hs $*`
if [ $? != 0 ]
then
 echo "$CALLER: Unknown flag(s)"
 usage
fi
 
# Note quotes around `$TEMP': they are essential! 
eval set -- "$TEMP"
 
while true                   
 do
  case "$1" in
   -h) usage "HELP";    shift;; # Help requested
   -s) SILENT="yes";    shift;; # Prompt not needed
   --) shift ; break ;; 
   *) echo "Internal error!" ; exit 1 ;;
  esac
 done
 
# ------------------------------------------------
# The following environment variables must be set
# ------------------------------------------------
 
if [ -z "$TEST_VAR" ]
then
  echo "Environment variable TEST_VAR is not set."
  usage
fi

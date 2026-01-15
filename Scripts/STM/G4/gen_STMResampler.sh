#!/usr/bin/bash
# Generate fcl files for resampling the hits generated with BeamToVD.fcl (both from EleBeamCat and MuBeamCat)
# Generates a sets of fcl files found in directories STMResampler_00X
# Usage - Run this command as a shell script with the following arguments
#  - $1 is the production (ie MDC2020)
#  - $2 is the input production version
#  - $3 is the output production version
#  - $4 is the number of jobs
#  - $5 is the number of jobs
#  - $6 is the project name of the BeamToVD.fcl grid job. If not given, then it is assumed that the text file containing all the input datasets
#    are listed in a file called STMDatasetList.txt with a single line at the end containing the number of events in the named STMDatasetList.txt.
#    This works under the assumption that all jobs in the output directory are associated with the BeamToVD.fcl grid job
# Original author: Pawel Plesniak

# Check all arguments are present
if [[ ${5} == "" ]]; then
  echo "Missing arguments!"
  return -1
fi

# TODO BEFORE NEXT CAMPAIGN - rewrite this to use the SAM tools samCountFiles.sh and samCountEvents.sh
# Create the input dataset list STMDatasetList.txt
if [[ ${6} != "" ]]; then
  # Setup path to job path
  jobDir="/pnfs/mu2e/scratch/users/"$USER"/workflow/"$6"/outstage/*/*/*/*.art"

  # Remove the existing file list
  echo "Generating STMDatasetList.txt"
  if [ -f STMDatasetList.txt ]; then
    echo "Removing pre-existing STMDatasetList.txt"
    rm STMDatasetList.txt;
  fi

  # Generate the new file list
  echo "Finding all the input datasets"
  find $jobDir -type f -name "*.art" > STMDatasetList.txt;

  # Check that any files are found
  nFiles=$(wc -c < "STMDatasetList.txt")
  if [[ "$nFiles" -eq 0 ]]; then
    echo "Path passed is empty, validate that the constructed path $jobDir is correct."
  fi

  # Count the number of events 
  echo "Counting the number of events in the given path. Note - this is likely to take a few mins especially if there are a lot of files"
  tail=`mu2e -c Offline/Print/fcl/count.fcl -S STMDatasetList.txt | tail -n 30 | grep "Event records" | xargs`
  tailArray=($tail)
  nEvents=${tailArray[0]}

  # Append the number of events to the file
  echo ${nEvents} >> STMDatasetList.txt
  echo "Finished generating STMDatasetList.txt"
else
  echo "Using existing STMDatasetList.txt"

  # Check if the file with the list of data files and the total number of events on the last line exists
  if [ ! -f STMDatasetList.txt ]; then
      echo "No dataset list file called STMDatasetList.txt, exiting"
      return
  fi

  # Get the number of events from the last line of the file
  nEvents=`tail -n 1 STMDatasetList.txt | xargs`

  # Check that there are events present
  if [[ "$nEvents" -eq 0 ]]; then
    echo "File indicates no events."
  fi

  # Check if the last line is a number
  if [[ ! $nEvents =~ ^[-+]?[0-9]+$ ]]; then
    echo "Passed entry is not an integer, make sure that the last line in this file corresponds to the total number of events in the files you have used in this file!"
    return
  fi
fi

# Count the number of jobs and files
nFiles=`wc -l STMDatasetList.txt`
nFiles=($nFiles)

# Validate and account for a newline character being present
lastLine=$(tail -c 1 STMDatasetList.txt)
if [[ "$lastLine" == '' ]]; then
  nFiles=$((nFiles[0]-1))
fi

# Calculate the number of events to skip
nSkip=$((nEvents/nFiles))
echo "Found $nEvents events over $nFiles files. Setting MaxEventsToSkip as $nSkip"

# Create a copy of STMDatasetList.txt without the event count at the end
if [ -f STMDatasetListNoCount.txt ]; then
  echo "Removing pre-existing STMDatasetListNoCount.txt"
  rm -f STMDatasetListNoCount.txt
fi
head -n ${nFiles} STMDatasetList.txt > STMDatasetListNoCount.txt

# Write the template fcl
if [ -f tmp.fcl ]; then
    rm -f tmp.fcl
fi
echo '#include "Production/JobConfig/pileup/STM/STMResampler.fcl"' >> tmp.fcl
echo physics.filters.stmResamplerBeamCatDatasets.mu2e.MaxEventsToSkip: ${nSkip} >> tmp.fcl

# Generate the STMResampler fcl files
generate_fcl --dsconf=$1$3 --dsowner=$USER --run-number=1204 --description=STMResampler --events-per-job=$5 --njobs=$4 \
  --embed tmp.fcl --auxinput=1:physics.filters.stmResamplerBeamCatDatasets.fileNames:STMDatasetListNoCount.txt

# Move the generated fcl files (in their directories) to a uniquely identifiable area
for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf STMResampler_$dirname
  mv $dirname STMResampler_$dirname
 fi
done

# Save the seed file to a directory
seedDir="STMResamplerSeeds"
if [ ! -d $seedDir ]; then
  mkdir $seedDir
fi
mv seeds.$USER.STMResampler*.$1$3.*.txt $seedDir

# Cleanup
echo "Removing temporary files"
rm -f STMDatasetListNoCount.txt
rm -f tmp.fcl
echo "Finished"

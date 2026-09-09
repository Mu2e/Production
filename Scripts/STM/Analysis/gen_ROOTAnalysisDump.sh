# Generates the ROOT dump fcl files for the EleBeamCat and MuBeamCat datasets
# This requires a file containing the list of outut files generated from using gen_BeamToVD.sh and gen_BeamToVD1809.sh
# For the study defined in docdb 51487, the input files are:
#   S1E1.txt - Stage 1 EleBeamCat (found in dataset sim.plesniak.Stage1.Ele1.art)
#   S1E2.txt - Stage 1 EleBeamCat (found in dataset sim.plesniak.Stage1.Ele2.art)
#   S1M1.txt - Stage 1 MuBeamCat (found in dataset sim.plesniak.Stage1.Mu1.art)
#   S1M2.txt - Stage 1 MuBeamCat (found in dataset sim.plesniak.Stage1.Mu2.art)
#   S1M3.txt - Stage 1 MuBeamCat (found in dataset sim.plesniak.Stage1.Mu3.art)
#   S11809.txt - Stage 1 1809 TargetStopsCat (found in dataset dts.plesniak.Stage1.1809.art) - note there was a problem with the upload, and the exact statistics used to generate these files is unknown
#   etc...
# This is simply a driver code, which should be configured in Offline/STMMC/fcl/ROOTAnalysisDump.fcl
# Usage
#   - Generate the input files using gen_BeamToVD.sh and gen_BeamToVD1809.sh
#   - Edit Offline/STMMC/fcl/ROOTAnalysisDump.fcl to select which data you want to dump to ROOT TTrees
#   - Run this script: ./gen_ROOTAnalysisDump.sh
# Original author: Pawel Plesniak

# Prepare the fcl file that contains the driver code to trace the SimParticles
if [ -f tmp.fcl ]; then
  rm -f tmp.fcl
fi
echo '#include "Production/JobConfig/pileup/STM/SignalParticleTrace.fcl"' > tmp.fcl

# Cleanup any previous script runs
rm -rf 000 001 002 003 004 005 006 007 008 009
rm -rf S1E1_00* S1E2_00* S1M1_00* S1M2_00* S1M3_00* S11809_00* S2E1_00* S2E2_00* S2M1_00* S2M2_00*


# Generate the Stage 1 EleBeamCat tracing fcl files
nFiles=`wc -l S1E1.txt| cut -d ' ' -f1`
echo "Found $nFiles S1E1 files"
generate_fcl --dsconf=MDC2020p --description=S1E1 --embed tmp.fcl --inputs S1E1.txt --merge-factor 1000
echo "Generated `ls -1 000/*.fcl | wc -l` jobs in S1E1_000"

for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf S1E1_$dirname
  mv $dirname S1E1_$dirname
  tmp=`ls -1 S1E1_$dirname/*.fcl | wc -l`
 fi
done

nFiles=`wc -l S1E2.txt| cut -d ' ' -f1`
echo "Found $nFiles S1E2 files"
generate_fcl --dsconf=MDC2020p --description=S1E2 --embed tmp.fcl --inputs S1E2.txt --merge-factor 1000
echo "Generated `ls -1 000/*.fcl | wc -l` jobs in S1E2_000"

for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf S1E2_$dirname
  mv $dirname S1E2_$dirname
  tmp=`ls -1 S1E2_$dirname/*.fcl | wc -l`
 fi
done


# Generate the Stage 1 MuBeamCat tracing fcl files
nFiles=`wc -l S1M1.txt| cut -d ' ' -f1`
echo "Found $nFiles S1M1 files"
generate_fcl --dsconf=MDC2020p --description=S1M1 --embed tmp.fcl --inputs S1M1.txt --merge-factor 1000
echo "Generated `ls -1 000/*.fcl | wc -l` jobs in S1M1_000"

for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf S1M1_$dirname
  mv $dirname S1M1_$dirname
  tmp=`ls -1 S1M1_$dirname/*.fcl | wc -l`
 fi
done

nFiles=`wc -l S1M2.txt| cut -d ' ' -f1`
echo "Found $nFiles S1M2 files"
generate_fcl --dsconf=MDC2020p --description=S1M2 --embed tmp.fcl --inputs S1M2.txt --merge-factor 1000
echo "Generated `ls -1 000/*.fcl | wc -l` jobs in S1M2_000"

for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf S1M2_$dirname
  mv $dirname S1M2_$dirname
  tmp=`ls -1 S1M2_$dirname/*.fcl | wc -l`
 fi
done

nFiles=`wc -l S1M3.txt| cut -d ' ' -f1`
echo "Found $nFiles S1M3 files"
generate_fcl --dsconf=MDC2020p --description=S1M3 --embed tmp.fcl --inputs S1M3.txt --merge-factor 1000
echo "Generated `ls -1 000/*.fcl | wc -l` jobs in S1M3_000"

for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf S1M3_$dirname
  mv $dirname S1M3_$dirname
  tmp=`ls -1 S1M3_$dirname/*.fcl | wc -l`
 fi
done

# Generate the Stage 1 1809 TargetStopsCat tracing fcl files
nFiles=`wc -l S11809.txt| cut -d ' ' -f1`
echo "Found $nFiles S11809 files"
generate_fcl --dsconf=MDC2020p --description=S11809 --embed tmp.fcl --inputs S11809.txt --merge-factor 1000
echo "Generated `ls -1 000/*.fcl | wc -l` jobs in S11809_000"

for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf S11809_$dirname
  mv $dirname S11809_$dirname
  tmp=`ls -1 S11809_$dirname/*.fcl | wc -l`
 fi
done

# Generate the Stage 2 EleBeamCat tracing fcl files
nFiles=`wc -l S2E1.txt| cut -d ' ' -f1`
echo "Found $nFiles S2E1 files"
generate_fcl --dsconf=MDC2020p --description=S2E1 --embed tmp.fcl --inputs S2E1.txt --merge-factor 1000
echo "Generated `ls -1 000/*.fcl | wc -l` jobs in S2E1_000"

for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf S2E1_$dirname
  mv $dirname S2E1_$dirname
  tmp=`ls -1 S2E1_$dirname/*.fcl | wc -l`
 fi
done

nFiles=`wc -l S2E2.txt| cut -d ' ' -f1`
echo "Found $nFiles S2E2 files"
generate_fcl --dsconf=MDC2020p --description=S2E2 --embed tmp.fcl --inputs S2E2.txt --merge-factor 1000
echo "Generated `ls -1 000/*.fcl | wc -l` jobs in S2E2_000"

for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf S2E2_$dirname
  mv $dirname S2E2_$dirname
  tmp=`ls -1 S2E2_$dirname/*.fcl | wc -l`
 fi
done

# Generate the Stage 2 MuBeamCat tracing fcl files
nFiles=`wc -l S2M1.txt| cut -d ' ' -f1`
echo "Found $nFiles S2M1 files"
generate_fcl --dsconf=MDC2020p --description=S2M1 --embed tmp.fcl --inputs S2M1.txt --merge-factor 1000
echo "Generated `ls -1 000/*.fcl | wc -l` jobs in S2M1_000"

for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf S2M1_$dirname
  mv $dirname S2M1_$dirname
  tmp=`ls -1 S2M1_$dirname/*.fcl | wc -l`
 fi
done

nFiles=`wc -l S2M2.txt| cut -d ' ' -f1`
echo "Found $nFiles S2M2 files"
generate_fcl --dsconf=MDC2020p --description=S2M2 --embed tmp.fcl --inputs S2M2.txt --merge-factor 1000
echo "Generated `ls -1 000/*.fcl | wc -l` jobs in S2M2_000"

for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf S2M2_$dirname
  mv $dirname S2M2_$dirname
  tmp=`ls -1 S2M2_$dirname/*.fcl | wc -l`
 fi
done



# Cleanup
echo "Removing temporary files"
rm -f tmp.fcl
echo "Finished"

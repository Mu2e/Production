#!/usr/bin/bash
#
# create fcl for producing primaries from stopped particles
# starting from a given primary that allows to set:
# pdgID, startMom and endMom. 
# Tested with the FlateMinus/Plus primaries
#
# this script requires mu2etools and dhtools be setup
#
# $1 is the primary
# $2 is the production (ie MDC2020)
# $3 is the stops production version
# $4 is the output primary production version
# $5 is the kind of input stops (Muminus, Muplus, IPAMuminus, IPAMuplus, or Cosmic)
# $6 is the number of jobs
# $7 is the number of events/job
# $8 is the pdgId of the particle to generate
# $9 is the startMom
# $10 is the endMom
# $11 is the name of the BField file
#
# example for running this script:
#        source Production/Scripts/gen_FlatMuDaughter.sh FlatePlus MDC2020 k s Muminus 2 100 -11 30 100 "Offline/Mu2eG4/geom/bfgeom_DS70_no_tsu_ps_v01.txt"

if [[ $# -lt 7 ]]; then
  echo "Missing arguments, provided $# but there should be 7"
  return 1
fi
primary=$1
stopsconf=$2$3
primaryconf=$2$4
stype=$5
njobs=$6
eventsperjob=$7
pdg=$8
startMom=$9
endMom=${10}
bFieldFile=${11}

echo PDG=$pdg
echo startMom=$startMom
echo endMom=$endMom
echo bField=$bFieldFile

if [[ "${stype}" == "Muminus" ]] ||  [[ "${stype}" == "Muplus" ]]; then
  dataset=sim.mu2e.${stype}StopsCat.${stopsconf}.art
  resampler=TargetStopResampler
elif [[ "${stype}" == "Cosmic" ]]; then
  dataset=sim.mu2e.${stype}DSStops${primary}.${stopsconf}.art   # should have Cat FIXME!
  resampler=${stype}Resampler
else
  dataset=sim.mu2e.${stype}StopsCat.${stopsconf}.art
  resampler=${stype}StopResampler
fi

samweb list-file-locations --schema=root --defname="$dataset"  | cut -f1 > Stops.txt
# calucate the max skip from the dataset
nfiles=`samCountFiles.sh $dataset`
nevts=`samCountEvents.sh $dataset`
let nskip=nevts/nfiles
# write the template
rm primary.fcl
if [[ "${stype}" == "Cosmic" ]]; then
  echo "#include \"Production/JobConfig/cosmic/S2Resampler${primary}.fcl\"" >> primary.fcl
else
  echo "#include \"Production/JobConfig/primary/${primary}.fcl\"" >> primary.fcl
fi
echo physics.filters.${resampler}.mu2e.MaxEventsToSkip: ${nskip} >> primary.fcl
echo physics.filters.${resampler}.mu2e.MaxEventsToSkip: ${nskip} >> primary.fcl
echo physics.producers.generate.pdgId: ${pdg}            >> primary.fcl
echo physics.producers.generate.startMom: ${startMom}    >> primary.fcl
echo physics.producers.generate.endMom: ${endMom}        >> primary.fcl
echo services.GeometryService.bFieldFile: \"${bFieldFile}\">> primary.fcl

#
# now generate the fcl
#
generate_fcl --dsconf=${primaryconf} --dsowner=mu2e --run-number=1202 --description=${primary} --events-per-job=${eventsperjob} --njobs=${njobs} \
  --embed primary.fcl --auxinput=1:physics.filters.${resampler}.fileNames:Stops.txt 
for dirname in 000 001 002 003 004 005 006 007 008 009; do
 if test -d $dirname; then
  echo "found dir $dirname"
  rm -rf ${primary}\_$dirname
  mv $dirname ${primary}\_$dirname
 fi
done


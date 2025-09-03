#!/bin/bash
usage() { echo "Usage: $0
  to use make a dir and cp logs (called logs)
  e.g. validatelogs.sh --tag MDS1b --release MDC2020 --version ai
"
}

# Function: Exit with error.
exit_abnormal() {
  usage
  exit 1
}

RELEASE=MDC2020
VERSION=at
TAG="" # MDS1a
CONFIG=""
# Loop: Get the next option;
while getopts ":-:" options; do
  case "${options}" in
    -)
      case "${OPTARG}" in
        release)
          RELEASE=${!OPTIND} OPTIND=$(( $OPTIND + 1 ))
          ;;
        version)
          VERSION=${!OPTIND} OPTIND=$(( $OPTIND + 1 ))
          ;;
        tag)
          TAG=${!OPTIND} OPTIND=$(( $OPTIND + 1 ))
          ;;
        config)
          CONFIG=${!OPTIND} OPTIND=$(( $OPTIND + 1 ))
          ;;
        *)
          echo "Unknown option " ${OPTARG}
          exit_abnormal
          ;;
        esac;;
    :)                                    # If expected argument omitted:
      echo "Error: -${OPTARG} requires an argument."
      exit_abnormal                       # Exit abnormally.
      ;;
    *)                                    # If unknown (any other) option:
      exit_abnormal                       # Exit abnormally.
      ;;
    esac
done

rm *.txt

ls logs/* &> logs.txt

while IFS='= ' read -r col1
do
  temp=$(sed -n '/Dataset        Counts /, /Dataset Counts/ p' ${col1})
  echo $temp >> gen.txt
done < logs.txt

temp=$(sed -r  's/.* DIO ([^ ]+).*/\1/' gen.txt) 
echo $temp >> DIO.txt
sed -i -e 's/ /\n/g' DIO.txt
temp2=$(awk '{s+=$1} END {print s}' DIO.txt)
echo "total DIO " ${temp2}

temp=$(sed -r  's/.* CRYCosmic ([^ ]+).*/\1/' gen.txt) 
echo $temp >> cosmic.txt
sed -i -e 's/ /\n/g' cosmic.txt
temp2=$(awk '{s+=$1} END {print s}' cosmic.txt)
echo "total cosmic " ${temp2}

temp=$(sed -r  's/.* RPCInternal ([^ ]+).*/\1/' gen.txt) 
echo $temp >> intRPC.txt
sed -i -e 's/ /\n/g' intRPC.txt
temp2=$(awk '{s+=$1} END {print s}' intRPC.txt)
echo "total internal RPC " ${temp2}

temp=$(sed -r  's/.* RPCExternal ([^ ]+).*/\1/' gen.txt) 
echo $temp >> extRPC.txt
sed -i -e 's/ /\n/g' extRPC.txt
temp2=$(awk '{s+=$1} END {print s}' extRPC.txt)
echo "total external RPC " ${temp2}

temp=$(sed -r  's/.* RMCInternal ([^ ]+).*/\1/' gen.txt) 
echo $temp >> intRMC.txt
sed -i -e 's/ /\n/g' intRMC.txt
temp2=$(awk '{s+=$1} END {print s}' intRMC.txt)
echo "total internal RMC " ${temp2}

temp=$(sed -r  's/.* RMCExternal ([^ ]+).*/\1/' gen.txt) 
echo $temp >> extRMC.txt
sed -i -e 's/ /\n/g' extRMC.txt
temp2=$(awk '{s+=$1} END {print s}' extRMC.txt)
echo "total external RMC " ${temp2}

temp=$(sed -r  's/.* IPAMichel ([^ ]+).*/\1/' gen.txt) 
echo $temp >> ipa.txt
sed -i -e 's/ /\n/g' ipa.txt
temp2=$(awk '{s+=$1} END {print s}' ipa.txt)
echo "total ipa " ${temp2}


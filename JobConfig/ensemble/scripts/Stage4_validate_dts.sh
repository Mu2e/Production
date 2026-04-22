#!/bin/bash
usage() { echo "Usage: $0
  to use make a dir and cp logs (called logs)
  e.g. Stage4_validate_dts.sh --tag MDS1b --release MDC2020 --version ai
"
}

# Function: Exit with error.
exit_abnormal() {
  usage
  exit 1
}

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🔍 Stage 4: DTS Dataset Validation"
echo "   Analyzing job logs for generated event counts"
echo "═══════════════════════════════════════════════════════════════"
echo ""

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

echo "[1/4] Cleaning up previous outputs..."
rm *.txt 2>/dev/null
echo "   ✓ Previous temporary files removed"
echo ""

echo "[2/4] Extracting log files..."
ls logs/* &> logs.txt
log_count=$(wc -l < logs.txt)
echo "   ✓ Found ${log_count} log files"
echo ""

echo "[3/4] Parsing dataset counts from logs..."
while IFS='= ' read -r col1
do
  temp=$(sed -n '/Dataset        Counts /, /Dataset Counts/ p' ${col1})
  echo $temp >> gen.txt
done < logs.txt
echo "   ✓ Extracted dataset information"
echo ""

echo "[4/4] Aggregating event counts by dataset:"
echo ""

# DIO
temp=$(sed -r  's/.* DIO ([^ ]+).*/\1/' gen.txt) 
echo $temp >> DIO.txt
sed -i -e 's/ /\n/g' DIO.txt
temp2=$(awk '{s+=$1} END {print s}' DIO.txt)
echo "   📊 DIO:                ${temp2} total generated events"

# CRYCosmic
temp=$(sed -r  's/.* CRYCosmic ([^ ]+).*/\1/' gen.txt) 
echo $temp >> cosmic.txt
sed -i -e 's/ /\n/g' cosmic.txt
temp2=$(awk '{s+=$1} END {print s}' cosmic.txt)
echo "   📊 CRYCosmic:          ${temp2} total generated events"

# RPC Internal
temp=$(sed -r  's/.* RPCInternal ([^ ]+).*/\1/' gen.txt) 
echo $temp >> intRPC.txt
sed -i -e 's/ /\n/g' intRPC.txt
temp2=$(awk '{s+=$1} END {print s}' intRPC.txt)
echo "   📊 RPC Internal:       ${temp2} total generated events"

# RPC External
temp=$(sed -r  's/.* RPCExternal ([^ ]+).*/\1/' gen.txt) 
echo $temp >> extRPC.txt
sed -i -e 's/ /\n/g' extRPC.txt
temp2=$(awk '{s+=$1} END {print s}' extRPC.txt)
echo "   📊 RPC External:       ${temp2} total generated events"

# RMC Internal
temp=$(sed -r  's/.* RMCInternal ([^ ]+).*/\1/' gen.txt) 
echo $temp >> intRMC.txt
sed -i -e 's/ /\n/g' intRMC.txt
temp2=$(awk '{s+=$1} END {print s}' intRMC.txt)
echo "   📊 RMC Internal:       ${temp2} total generated events"

# RMC External
temp=$(sed -r  's/.* RMCExternal ([^ ]+).*/\1/' gen.txt) 
echo $temp >> extRMC.txt
sed -i -e 's/ /\n/g' extRMC.txt
temp2=$(awk '{s+=$1} END {print s}' extRMC.txt)
echo "   📊 RMC External:       ${temp2} total generated events"

# IPA Michel
temp=$(sed -r  's/.* IPAMichel ([^ ]+).*/\1/' gen.txt) 
echo $temp >> ipa.txt
sed -i -e 's/ /\n/g' ipa.txt
temp2=$(awk '{s+=$1} END {print s}' ipa.txt)
echo "   📊 IPA Michel:         ${temp2} total generated events"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Validation Complete!"
echo "   Results saved to individual dataset .txt files"
echo "═══════════════════════════════════════════════════════════════"
echo ""


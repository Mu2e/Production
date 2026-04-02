#!/usr/bin/bash
usage() { echo "Usage: $0
  e.g. Stage2b_uploadtar.sh --tag MDS3c --release MDC2025 --version af
"
}

# Function: Exit with error.
exit_abnormal() {
  usage
  exit 1
}

# Default values
TAG=""
RELEASE="MDC2025"
VERSION="ag"
OWNER="sophie"

# Loop: Get the next option
while getopts ":-:" options; do
  case "${options}" in
    -)
      case "${OPTARG}" in
        tag)
          TAG=${!OPTIND} OPTIND=$(( $OPTIND + 1 ))
          ;;
        release)
          RELEASE=${!OPTIND} OPTIND=$(( $OPTIND + 1 ))
          ;;
        version)
          VERSION=${!OPTIND} OPTIND=$(( $OPTIND + 1 ))
          ;;
        owner)
          OWNER=${!OPTIND} OPTIND=$(( $OPTIND + 1 ))
          ;;
        *)
          echo "Unknown option " ${OPTARG}
          exit_abnormal
          ;;
        esac;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit_abnormal
      ;;
    *)
      exit_abnormal
      ;;
    esac
done

# Validate required parameters
if [[ -z ${TAG} ]]; then
  echo "Error: --tag parameter is required"
  exit_abnormal
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "📤 Stage 2b: Upload TAR file to Storage"
echo "   Tag: ${TAG} | Release: ${RELEASE}${VERSION} | Owner: ${OWNER}"
echo "═══════════════════════════════════════════════════════════════"
echo ""

TAR_FILE="cnf.${OWNER}.ensemble${TAG}.${RELEASE}${VERSION}.0.tar"
CONFIG_FILE="${TAG}.txt"
JSON_FILE="${TAG}.json"

echo "🔍 [1/3] Checking for TAR file and config..."
if [[ ! -f ${TAR_FILE} ]]; then
  echo "   ✗ Error: TAR file not found: ${TAR_FILE}"
  echo "   Make sure Stage 2 (Stage2_submitensemble_v2.sh) has been run"
  exit 1
fi
if [[ ! -f ${CONFIG_FILE} ]]; then
  echo "   ✗ Error: Config file not found: ${CONFIG_FILE}"
  exit 1
fi
echo "   ✓ Found ${TAR_FILE}"
echo "   ✓ Found ${CONFIG_FILE}"
echo ""

echo "📋 [2/3] Generating JSON metadata..."
# Source the config file to get njobs
source ${CONFIG_FILE}

# Create JSON with metadata including full pipeline stages
cat > ${JSON_FILE} << EOF
[
  {
    "desc": "ensemble${TAG}",
    "tarball": "${TAR_FILE}",
    "njobs": ${njobs},
    "inloc": "disk",
    "outloc": {"dts.*.art": "tape"}
  },
  {
    "desc": "ensemble${TAG}OnSpill",
    "dsconf": "${RELEASE}${VERSION}_best_v1_3",
    "fcl": "Production/JobConfig/digitize/OnSpill.fcl",
    "input_data": {
      "dts.mu2e.ensemble${TAG}.${RELEASE}${VERSION}.art": ${njobs}
    },
    "fcl_overrides": {
      "services.DbService.purpose": "Sim_best",
      "services.DbService.version": "v1_1",
      "outputs.TriggeredOutput.fileName": "dig.owner.{desc}Triggered.version.sequencer.art",
      "outputs.TriggerableOutput.fileName": "dig.owner.{desc}Triggerable.version.sequencer.art"
    },
    "inloc": "tape",
    "outloc": {"*.art": "tape"},
    "simjob_setup": "/cvmfs/mu2e.opensciencegrid.org/Musings/SimJob/${RELEASE}${VERSION}/setup.sh"
  },
  {
    "desc": "ensemble${TAG}OnSpillTriggeredReco",
    "dsconf": "${RELEASE}${VERSION}_best_v1_3",
    "fcl": "Production/JobConfig/recoMC/OnSpill.fcl",
    "input_data": {
      "dig.mu2e.ensemble${TAG}OnSpillTriggered.${RELEASE}${VERSION}_best_v1_3.art": 1
    },
    "fcl_overrides": {
      "services.DbService.purpose": "Sim_best",
      "services.DbService.version": "v1_1",
      "outputs.LoopHelixOutput.fileName": "mcs.owner.ensemble${TAG}OnSpillTriggered.version.sequencer.art"
    },
    "inloc": "tape",
    "outloc": {"*.art": "tape"},
    "simjob_setup": "/cvmfs/mu2e.opensciencegrid.org/Musings/SimJob/${RELEASE}${VERSION}/setup.sh"
  },
  {
    "desc": "ensemble${TAG}Ntuple",
    "dsconf": ["${RELEASE}-001"],
    "fcl": ["EventNtuple/fcl/from_mcs-mockdata.fcl"],
    "input_data": {
      "mcs.mu2e.ensemble${TAG}OnSpillTriggered.${RELEASE}${VERSION}_best_v1_3.art": 1
    },
    "fcl_overrides": {
      "services.TFileService.fileName": "nts.mu2e.{desc}.version.sequencer.root"
    },
    "inloc": "tape",
    "outloc": {"*.root": "disk"},
    "simjob_setup": "/cvmfs/mu2e.opensciencegrid.org/Musings/AnalysisMDC2025/v01_01_03/setup.sh"
  }
]
EOF

if [[ ! -f ${JSON_FILE} ]]; then
  echo "   ✗ Error: Failed to generate JSON file"
  exit 1
fi
echo "   ✓ Generated ${JSON_FILE}"
echo ""

echo "📤 [3/3] Uploading files to storage..."
echo "   Declaring files to SAM..."
ls *.json | mu2eFileDeclare
if [[ $? -ne 0 ]]; then
  echo "   ✗ Error: Failed to declare files"
  exit 1
fi
echo "   ✓ Files declared"
echo ""

echo "   Uploading TAR file to tape..."
UPLOAD_OUTPUT=$(ls *.tar | mu2eFileUpload --tape 2>&1)
UPLOAD_STATUS=$?

if [[ ${UPLOAD_STATUS} -ne 0 ]]; then
  echo "   ✗ Error: Failed to upload TAR file"
  exit 1
fi

# Extract tape path from upload output (format: "to /pnfs/mu2e/tape/... on")
TAPE_PNFS=$(echo "${UPLOAD_OUTPUT}" | grep "to /" | sed 's/.*to \(\/pnfs[^ ]*\) on.*/\1/' | head -1)

if [[ -z ${TAPE_PNFS} ]]; then
  echo "   ✗ Error: Could not extract tape path from upload output"
  echo "   Output was: ${UPLOAD_OUTPUT}"
  exit 1
fi

# Remove the filename from the path to get directory
TAPE_DIR=$(dirname "${TAPE_PNFS}")
TAPE_PATH="enstore:${TAPE_DIR}"

echo "   ✓ TAR file uploaded"
echo "   Tape location: ${TAPE_DIR}"
echo ""

echo "   Adding file location to SAM..."
samweb add-file-location ${TAR_FILE} ${TAPE_PATH}
if [[ $? -ne 0 ]]; then
  echo "   ✗ Error: Failed to add file location"
  exit 1
fi
echo "   ✓ File location registered"
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "✅ Stage 2b Complete!"
echo "   TAR file uploaded: ${TAR_FILE}"
echo "   Tape location: ${TAPE_PATH}"
echo "═══════════════════════════════════════════════════════════════"
echo ""

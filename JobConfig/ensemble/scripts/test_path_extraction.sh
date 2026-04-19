#!/bin/bash

# Test script to validate path extraction logic from mu2eFileUpload output

echo "Testing path extraction from mu2eFileUpload output..."
echo ""

# Simulate the output from mu2eFileUpload
UPLOAD_OUTPUT="0  Starting to transfer 2501120 bytes in cnf.mu2e.ensembleMDS3c.MDC2025af.0.tar to /pnfs/mu2e/persistent/datasets/phy-etc/cnf/mu2e/ensembleMDS3c/MDC2025af/tar/f8/b1/cnf.mu2e.ensembleMDS3c.MDC2025af.0.tar on Fri Apr  3 08:42:04 2026
	22.5519671187611 MiB/s
Summary: copied  1 and moved 0 files in 0.193927 seconds.
The average throughput was 2.39 MiB in 0.105767 s = 22.55 MiB/s"

echo "Raw output from mu2eFileUpload:"
echo "═══════════════════════════════════════════════════════════════"
echo "${UPLOAD_OUTPUT}"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Extract tape path from upload output (format: "filename to /pnfs/mu2e/..." )
# Match " to " followed by path, capture up to first space (end of path)
TAPE_FILE=$(echo "${UPLOAD_OUTPUT}" | sed -n 's/.*to \(\/pnfs[^ ]*\).*/\1/p')

echo "Step 1: Extract path after 'to' (up to first space)"
echo "TAPE_FILE = ${TAPE_FILE}"
echo ""

if [[ -z ${TAPE_FILE} ]]; then
  echo "ERROR: Could not extract tape path from upload output"
  exit 1
fi

# Get directory path (remove filename)
TAPE_PNFS=$(dirname "${TAPE_FILE}")

echo "Step 2: Get directory (dirname)"
echo "TAPE_PNFS = ${TAPE_PNFS}"
echo ""

# Convert to enstore path
TAPE_PATH="enstore:${TAPE_PNFS}"

echo "Step 3: Convert to enstore format"
echo "TAPE_PATH = ${TAPE_PATH}"
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "✅ Final extracted path:"
echo "   ${TAPE_PATH}"
echo "═══════════════════════════════════════════════════════════════"

#!/bin/bash

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "⏱️  Livetime Checker: Computing Total Livetime"
echo "═══════════════════════════════════════════════════════════════"
echo ""

DTS="cosmics_2025.txt" # Edit with file names
TAG="MDS3a" # Edit as needed

echo "[1/3] Cleaning up previous outputs..."
rm *.livetime 2>/dev/null
echo "   ✓ Previous livetime files cleaned"
echo ""

echo "[2/3] Processing cosmic dataset for livetime values..."
echo "   Input file: ${DTS}"
echo "   Processing with FCL: Offline/Print/fcl/printCosmicLivetime.fcl"
mu2e -c Offline/Print/fcl/printCosmicLivetime.fcl -S ${DTS} | grep 'Livetime:' | awk -F: '{print $NF}' > ${TAG}.livetime
echo "   ✓ Livetime values extracted"
echo ""

echo "[3/3] Calculating total livetime..."
LIVETIME=$(awk '{sum += $1} END {print sum}' ${TAG}.livetime)
event_count=$(wc -l < ${TAG}.livetime)
echo "   ✓ Processed ${event_count} livetime entries"
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "✅ Livetime Calculation Complete!"
echo "   Total Livetime: ${LIVETIME}"
echo "   Tag: ${TAG}"
echo "   Results saved to: ${TAG}.livetime"
echo "═══════════════════════════════════════════════════════════════"
echo ""

echo ${LIVETIME}

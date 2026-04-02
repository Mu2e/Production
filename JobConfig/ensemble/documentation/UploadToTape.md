# 📤 Bash Script Documentation: Upload Configuration to Tape `Stage3_configure_ensemble_campaign.sh`

**Note:** This is actually Stage 2b in the pipeline. It runs after Stage 2 (Stage2_build_sampler.sh) and before Stage 4 (Stage4_signal.sh).

## **1. Overview**

This script uploads the ensemble job configuration TAR file to tape storage and registers it with the SAM (Sequential Access with Metadata) system. It serves as the bridge between job submission (Stage 2) and downstream processing stages, ensuring the configuration and metadata are archived for future reference.

| Component | Description |
| :--- | :--- |
| **Purpose** | Upload the ensemble configuration TAR file to tape, generate JSON metadata describing the job and all downstream processing stages, declare files to SAM, and register tape file locations. |
| **Prerequisites** | Must be run after `Stage2_build_sampler.sh` has successfully created the configuration TAR file (`cnf.${OWNER}.ensemble${TAG}.${RELEASE}${VERSION}.0.tar`). Requires Mu2e storage tools (`printJson`, `mu2eFileDeclare`, `mu2eFileUpload`, `samweb`). |
| **Outcome** | Configuration TAR file is archived on tape with complete metadata. JSON file with pipeline stages is generated and registered. Output dataset locations are tracked for downstream processing. |

## **2. Usage**

```
Stage3_configure_ensemble_campaign.sh [OPTIONS]
```

### **Required Arguments:**

| Argument | Variable | Default | Description |
| :--- | :--- | :--- | :--- |
| `--tag` | `TAG` | `""` | **REQUIRED.** The project tag (e.g., `MDS3c`) used to identify the ensemble. |

### **Optional Arguments:**

| Argument | Variable | Default | Description |
| :--- | :--- | :--- | :--- |
| `--release` | `RELEASE` | `MDC2025` | The Mu2e software release tag. |
| `--version` | `VERSION` | `af` | The version sub-tag of the software release. |
| `--owner` | `OWNER` | `sophie` | The owner of the dataset (username or `mu2e`). |

---

## **3. Execution Flow**

The script executes in three main phases: Validation, JSON Metadata Generation, and Upload & Registration.

### **Phase 1: Validation & Configuration Loading**

1. **Check Prerequisites:**
   - Verifies that the TAR file exists: `cnf.${OWNER}.ensemble${TAG}.${RELEASE}${VERSION}.0.tar`
   - Verifies that the config file exists: `${TAG}.txt`
   - Sources the config file to extract `njobs` parameter

2. **Validate Files:**
   ```bash
   if [[ ! -f ${TAR_FILE} ]]; then
     echo "✗ Error: TAR file not found"
     exit 1
   fi
   ```

   > **Key Concept:** Both files must exist and be accessible. The config file provides critical job metadata (`njobs`) for the JSON output.

### **Phase 2: JSON Metadata Generation**

1. **Create Pipeline Description JSON:**
   
   The script generates a JSON file (`${TAG}.json`) containing the complete ensemble processing pipeline. This includes:

   - **Stage 0 (Ensemble Generation):** The initial TAR file configuration
   - **Stage 1 (Digitization - OnSpill):** Digitizes ensemble events using OnSpill FCL
   - **Stage 2 (Reconstruction - OnSpillTriggeredReco):** Reconstructs digitized events
   - **Stage 3 (Analysis - Ntuple):** Produces analysis ntuples from reconstructed data

   Each stage includes:
   - `desc`: Descriptive name for the processing stage
   - `fcl`: FCL file path for the stage
   - `dsconf`: Dataset configuration tag
   - `input_data`: Map of input file patterns and number of copies
   - `fcl_overrides`: Service and output filename overrides
   - `inloc`/`outloc`: Input and output storage locations (disk/tape)
   - `simjob_setup`: Path to the simulation environment setup script

2. **Example Output Structure:**

   ```json
   [
     {
       "desc": "ensembleMDS3c",
       "tarball": "cnf.sophie.ensembleMDS3c.MDC2025af.0.tar",
       "njobs": 496,
       "inloc": "disk",
       "outloc": {"dts.*.art": "tape"}
     },
     {
       "desc": "ensembleMDS3cOnSpill",
       "dsconf": "MDC2025af_best_v1_3",
       "fcl": "Production/JobConfig/digitize/OnSpill.fcl",
       "input_data": {
         "dts.mu2e.ensembleMDS3c.MDC2025af.art": 496
       },
       ...
     }
   ]
   ```

   > **Key Concept:** The JSON file documents the complete data processing chain, allowing downstream jobs to reference consistent configurations and enabling reproducibility tracking.

### **Phase 3: Upload, Declaration, and Registration**

1. **Declare Files to SAM:**
   ```bash
   ls *.json | mu2eFileDeclare
   ```
   Registers the JSON metadata file with the SAM metadata system.

2. **Upload TAR File to Tape:**
   ```bash
   UPLOAD_OUTPUT=$(ls *.tar | mu2eFileUpload --tape 2>&1)
   TAPE_PNFS=$(echo "${UPLOAD_OUTPUT}" | grep "to /" | sed 's/.*to \(\/pnfs[^ ]*\) on.*/\1/' | head -1)
   ```
   - Uploads the configuration TAR to tape storage
   - **Dynamically extracts** the tape path from the upload output
   - Parses the "to /pnfs/..." path printed by `mu2eFileUpload`

   > **Key Concept:** The tape path extraction is dynamic, allowing the script to work across different tape storage configurations without hardcoding paths.

3. **Register Tape Location with SAM:**
   ```bash
   TAPE_DIR=$(dirname "${TAPE_PNFS}")
   TAPE_PATH="enstore:${TAPE_DIR}"
   samweb add-file-location ${TAR_FILE} ${TAPE_PATH}
   ```
   - Registers the tape location in SAM so downstream jobs can locate the file
   - Uses the `enstore:` protocol prefix for tape storage

---

## **4. Output Files**

| File | Purpose |
| :--- | :--- |
| `${TAG}.json` | Metadata describing the complete ensemble processing pipeline, including all downstream stages (digitization, reconstruction, analysis). Generated locally and declared to SAM. |
| `${TAR_FILE}` (on tape) | The ensemble job configuration, archived to tape for long-term storage and reproducibility tracking. |

---

## **5. Error Handling**

The script validates each step and provides clear error messages:

| Error | Cause | Resolution |
| :--- | :--- | :--- |
| TAR file not found | `Stage2_build_sampler.sh` has not been run, or script is in wrong directory | Run Stage 2 first, or navigate to the correct working directory |
| Config file not found | `Stage1_initate_ensemble.sh` output is missing | Run Stage 1 first to generate `${TAG}.txt` |
| Failed to generate JSON | Disk space or permission issue | Check available disk space and write permissions |
| Failed to upload TAR | Network/storage issue or tarball is corrupted | Check network connectivity and TAR file integrity |
| Could not extract tape path | `mu2eFileUpload` output format changed or upload failed | Check SAM and storage service status |
| Failed to add file location | SAM service issue or file already registered | Verify SAM service is running; may need to re-declare file |

---

## **6. Usage Examples**

### **Basic Usage (with defaults):**
```bash
Stage3_configure_ensemble_campaign.sh --tag MDS3c
```
Uses default release (MDC2025), version (af), owner (sophie).

### **Custom Release and Version:**
```bash
Stage3_configure_ensemble_campaign.sh --tag MDS3c --release MDC2025 --version bg --owner mu2e
```

### **Expected Output:**
```
═══════════════════════════════════════════════════════════════
📤 Stage 2b: Upload TAR file to Storage
   Tag: MDS3c | Release: MDC2025af | Owner: sophie
═══════════════════════════════════════════════════════════════

🔍 [1/3] Checking for TAR file and config...
   ✓ Found cnf.sophie.ensembleMDS3c.MDC2025af.0.tar
   ✓ Found MDS3c.txt

📋 [2/3] Generating JSON metadata...
   ✓ Generated MDS3c.json

📤 [3/3] Uploading files to storage...
   Declaring files to SAM...
   ✓ Files declared

   Uploading TAR file to tape...
   ✓ TAR file uploaded
   Tape location: /pnfs/mu2e/tape/usr-etc/cnf/sophie/ensembleMDS3c/MDC2025af/tar/f9/6f

   Adding file location to SAM...
   ✓ File location registered

═══════════════════════════════════════════════════════════════
✅ Stage 2b Complete!
   TAR file uploaded: cnf.sophie.ensembleMDS3c.MDC2025af.0.tar
   Tape location: enstore:/pnfs/mu2e/tape/usr-etc/cnf/sophie/ensembleMDS3c/MDC2025af/tar/f9/6f
═══════════════════════════════════════════════════════════════
```

---

## **7. Integration with Other Stages**

```
Stage 1: Stage1_initate_ensemble.sh
    ↓ Generates: ${TAG}.txt (config) + event calculations
    ↓
Stage 2: Stage2_build_sampler.sh
    ↓ Generates: cnf.${OWNER}.ensemble${TAG}.${RELEASE}${VERSION}.0.tar
    ↓
Stage 3: Stage3_configure_ensemble_campaign.sh ← YOU ARE HERE
    ↓ Generates: ${TAG}.json + uploads to tape
    ↓
Stage 4+: Downstream processing uses ${TAG}.json for pipeline definition
```

Downstream processing chains (digitization → reconstruction → analysis) reference the JSON metadata to understand input datasets, FCL configurations, and output locations.

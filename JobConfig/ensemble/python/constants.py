#! /usr/bin/env
"""
Physical constants and interaction rates used in Mu2e simulations.
References for these values can be found in the referenced documentation.
"""

# --- Muon Interactions ---
# Fraction of stopped muons that undergo nuclear capture
CAPTURES_PER_STOPPED_MUON = 0.609
# Rate of radiative muon capture (RMC) events resulting in a gamma ray > 57 MeV, per capture event
RMC_GT_57_PER_CAPTURE  = 1.43e-5 # Source: Phys. Rev. C 59, 2853 (1999)
# Fraction of stopped muons that undergo standard DIO (Decay In Orbit)
DIO_PER_STOPPED_MUON = 0.391 # Calculated as: 1 - CAPTURES_PER_STOPPED_MUON
# Rate of Incoming Particle Decay After Stopping (IPA)
IPA_DECAYS_PER_STOPPED_MUON  = 0.92990

# --- Pion Interactions ---
# Fraction of stopped pions that result in a Radiative Pion Capture (RPC)
RPC_PER_STOPPED_PION = 0.0215 # Source: Reference uploaded on DocDB-469
# --- Internal Conversion Ratios ---
# Ratio of internal conversion events per RMC event (assuming RPC value is applicable)
INTERNAL_PER_RMC = 0.00690
# Ratio of internal conversion events per RPC event
INTERNAL_RPC_PER_RPC = 0.00690 # Source: Reference uploaded on DocDB-717


# --- Mu2e Constants ---
SPILL=1.695e-6 # seconds per spill
ONEBB_DF = 0.323 # onspill fraction for one-bunch mode
TWOBB_DF = 0.246 # onspill fraction for two-bunch mode
ONEBB_PROTONS_PER_SPILL=1.58e7 # protons per 1695 ns spill in one-bunch mode
TWOBB_PROTONS_PER_SPILL=3.93e7  # protons per 1695 ns spill in two-bunch mode
ONEBB_POT_PER_CYCLE=4e12 # protons per 1.33 s cycle in one-bunch mode
TWOBB_POT_PER_CYCLE=8e12 # protons per 1.4 s cycle in two-bunch mode
ONEBB_CYCLE = 1.33 # seconds per cycle in one-bunch mode
TWOBB_CYCLE = 1.4 # seconds per cycle in two-bunch mode

# One booster batch at a reduced intensity of 1500 W, as used by the
# Run1B campaigns. Matches JobConfig/mixing/OneBB1500W.fcl. Same
# accelerator mode as 1BB, so it takes ONEBB_DF and ONEBB_CYCLE; only
# the intensity differs.
#
# Protons per spill follow from POT per cycle divided by the number of
# 1695 ns spills that fit in the onspill fraction of a cycle:
#
#   mode     | power    | POT/cycle / (DF x cycle / SPILL)     = protons/spill
#   ---------|----------|--------------------------------------|--------------
#   1BB1500W | 1.500 kW | 1.556e12 / (0.323 x 1.33 / 1.695e-6) = 6.141e6
#   1BB      | 3.855 kW |    4e12 / (0.323 x 1.33 / 1.695e-6)  = 1.578e7
#   2BB      | 7.324 kW |    8e12 / (0.246 x 1.40 / 1.695e-6)  = 3.937e7
#
# Power is POT_PER_CYCLE * 8 GeV / CYCLE, so it depends on the cycle
# time, not on the duty factor. Note 2BB delivers double the protons in
# a shorter spill (0.344 s against 0.430 s), which is why 1BB and 2BB
# are not a factor of two apart in protons per spill.
ONEBB1500W_POT_PER_CYCLE = 1.556e12 # protons per 1.33 s cycle at 1500 W
ONEBB1500W_PROTONS_PER_SPILL = 6.14e6 # protons per 1695 ns spill at 1500 W

#! /usr/bin/env
import DbService
import argparse
import ROOT
import math
import os


# get muon stopped rates from DB
dbtool = DbService.DbTool()
dbtool.init()
args=["print-run","--purpose","MDC2020_best","--version","v1_1","--run","1200","--table","SimEfficiencies2","--content"]
dbtool.setArgs(args)
dbtool.run()
rr = dbtool.getResult()


# get number of target muon stops:
target_stopped_mu_per_POT = 1.0
rate = 1.0
lines= rr.split("\n")
for line in lines:
    words = line.split(",")
    if words[0] == "MuminusStopsCat" or words[0] == "MuBeamCat" :
        #print(f"Including {words[0]} with rate {words[3]}")
        rate = rate * float(words[3])
        target_stopped_mu_per_POT = rate * 1000 
#print(f"Final stops rate muon {target_stopped_mu_per_POT}")



# get number of POTs in given livetime
def livetime_to_pot(livetime, run_mode = '1BB',printout=False): #livetime in seconds
    # numbers from SU2020 
    # see https://github.com/Mu2e/su2020/blob/master/analysis/pot_normalization.org
    NPOT = 0.
    if(run_mode == '1BB'):
      # 1BB
      mean_PBI_low = 1.6e7
      Tcycle = 1.33 #s
      onspill_dutyfactor = 0.323
      POT_per_cycle = 4e12
      #onspill_time = livetime*onspill_dutyfactor
      Ncycles = livetime/Tcycle
      NPOT = Ncycles * POT_per_cycle
      if( printout):
        print("Tcycle=",Tcycle)
        print("POT_per_cycle=",POT_per_cycle)
        print("onspilltime=",livetime*onspill_dutyfactor)
        print ("NPOT=",NPOT)
    if(run_mode == '2BB'):
      # 2BB
      mean_PBI_high = 3.9e7
      Tcycle = 1.4 #s
      onspill_dutyfactor = 0.246
      POT_per_cycle = 8e12
      #onspill_time = livetime*onspill_dutyfactor
      Ncycles = livetime/Tcycle
      NPOT = Ncycles * POT_per_cycle
      if( printout):
        print("Tcycle=",Tcycle)
        print("POT_per_cycle=",POT_per_cycle)
        print("onspilltime=",livetime*onspill_dutyfactor)
        print ("NPOT=",NPOT)
    return NPOT

# get number of ipa muon stops:
ipa_stopped_mu_per_POT = 1.0
rate = 1.0
lines= rr.split("\n")
for line in lines:
    words = line.split(",")
    if words[0] == "IPAStopsCat" or words[0] == "MuBeamCat" :
        #print(f"Including {words[0]} with rate {words[3]}")
        rate = rate * float(words[3])
        ipa_stopped_mu_per_POT = rate
#print(f"Final ipa stops rate {ipa_stopped_mu_per_POT}")

# get CE normalization:
def ce_normalization(livetime, rue, run_mode = '1BB'):
    POT = livetime_to_pot(livetime, run_mode)
    captures_per_stopped_muon = 0.609 # for Al
    #print(f"Expected CE's {POT * target_stopped_mu_per_POT * captures_per_stopped_muon * rue}")
    return POT * target_stopped_mu_per_POT * captures_per_stopped_muon * rue

# get IPA Michel normalization:
def ipaMichel_normalization(livetime):
    POT = livetime_to_pot(livetime)
    IPA_decays_per_stopped_muon = 0.92 # carbon....#TODO
    #print(f"Expected IPA Michel e- {POT * ipa_stopped_mu_per_POT * IPA_decays_per_stopped_muon}")
    return POT * ipa_stopped_mu_per_POT * IPA_decays_per_stopped_muon

# get DIO normalization:
def dio_normalization(livetime, emin, run_mode = '1BB'):
    POT = livetime_to_pot(livetime, run_mode)
    # calculate fraction of spectrum generated
    spec = open(os.path.join(os.environ["MUSE_WORK_DIR"],"Production/JobConfig/ensemble/heeck_finer_binning_2016_szafron.tbl")) 
    energy = []
    val = []
    for line in spec:
        energy.append(float(line.split()[0]))
        val.append(float(line.split()[1]))

    total_norm = 0
    cut_norm = 0
    for i in range(len(val)):
        total_norm += val[i]
        if energy[i] >= emin:
            cut_norm += val[i]

    DIO_per_stopped_muon = 0.391 # 1 - captures_per_stopped_muon

    physics_events = POT * target_stopped_mu_per_POT * DIO_per_stopped_muon
    #print(f"Expected DIO {physics_events* cut_norm/total_norm}")
    print("DIOfrac=",cut_norm/total_norm)
    return physics_events * cut_norm/total_norm


# note this returns CosmicLivetime not # of generated events
def cry_onspill_normalization(livetime, run_mode = '1BB'):
    onspill_dutyfactor = 1.
    if(run_mode == '1BB'):
      # 1BB
      onspill_dutyfactor = 0.323
    if(run_mode == '2BB'):
      # 2BB
      onspill_dutyfactor = 0.246
    #print(f"cosmics live time {livetime*onspill_dutyfactor}")
    return livetime*onspill_dutyfactor

# note this returns CosmicLivetime not # of generated events
def cry_offspill_normalization(livetime, run_mode = '1BB'):
    offspill_dutyfactor = 1.
    if(run_mode == '1BB'):
      # 1BB
      offspill_dutyfactor = 0.323
    if(run_mode == '2BB'):
      # 2BB
      offspill_dutyfactor = 0.246
    #print(f"cosmics live time {livetime*offspill_dutyfactor}")
    return livetime*offspill_dutyfactor
    
# note this returns CosmicLivetime not # of generated events
def corsika_onspill_normalization(livetime, run_mode = '1BB'):
    onspill_dutyfactor = 1.
    if(run_mode == '1BB'):
      # 1BB
      onspill_dutyfactor = 0.323
    if(run_mode == '2BB'):
      # 2BB
      onspill_dutyfactor = 0.246
    #print(f"cosmics live time {livetime*onspill_dutyfactor}")
    return livetime*onspill_dutyfactor

# note this returns CosmicLivetime not # of generated events
def corsika_offspill_normalization(livetime, run_mode = '1BB'):
    offspill_dutyfactor = 1.
    if(run_mode == '1BB'):
      # 1BB
      offspill_dutyfactor = 0.323
    if(run_mode == '2BB'):
      # 2BB
      offspill_dutyfactor = 0.246
    #print(f"cosmics live time {livetime*offspill_dutyfactor}")
    return livetime*offspill_dutyfactor
    
"""
# get stopped rates from DB
dbtool = DbService.DbTool()
dbtool.init()
args=["print-run","--purpose","MDC2020_best","--version","v1_1","--run","1200","--table","PiSimEfficiencies","--content"] 
dbtool.setArgs(args)
dbtool.run()
rpi = dbtool.getResult()


# get number of target pions stops:
target_stopped_pi_per_POT = 1.0
nstops = 1.0
target_stopped_pi_per_POT = 1.0
lines= rpi.split("\n")
for line in lines:
    words = line.split(",")
    if words[0] == "PiBeam" or words[0] == "PiminusStopsCat":
        target_stopped_pi_per_POT *= float(words[3]) # stops_per_POT
    if words[0] == "PiminusStopsCat":
        npistops = words[1]   
    if words[0] == "PiMinusFilter" :
        timeeff_times_stoprate = float(words[3])
        target_stopped_pi_per_POT *=  timeeff_times_stoprate
    if words[0] == "PiMinusFilter" :
        total_sum_of_weights = words[1]
"""


def rpc_normalization(livetime, tmin, internal, run_mode = '1BB'):
  POT = livetime_to_pot(livetime, run_mode)
  # hack: --> will come from new table eventually
  npistops = 1287106
  target_stopped_pi_per_POT =  0.01337 * 0.1670
  time_eff = 83146/npistops
  
  total_sum_of_weights = 1148
  selected_sum_of_weights = 0.178864

  # constants
  RPC_per_stopped_pion = 0.0215; # from reference, uploaded on docdb-469
  internalRPC_per_RPC = 0.00690; # from reference, uploaded on docdb-717
  # calculate survival probability for tmin including smearing of POT
  avg_survival_prob = total_sum_of_weights/npistops;
  if(internal == 1): 
    print("pistoprate",target_stopped_pi_per_POT)
    print("pitimeeff", time_eff)
    print("pisurv", avg_survival_prob)
    print("pitotalweight", total_sum_of_weights)
  physics_events = POT * target_stopped_pi_per_POT * time_eff * RPC_per_stopped_pion * avg_survival_prob * selected_sum_of_weights/total_sum_of_weights

  if int(internal) == 1:
    physics_events *= internalRPC_per_RPC;
  return physics_events

def rmc_normalization(livetime, emin, kmax,internal, run_mode = '1BB'):
  POT = livetime_to_pot(livetime, run_mode)
  energy = []
  val = []
  # closure approximation as implemented in MuonCaptureSpectrum.cc
  for i in range(int((kmax-57.05)/0.1)):
    temp_e = 57.05 + i*0.1
    xFit = temp_e/kmax
    energy.append(temp_e)
    val.append((1 - 2*xFit +2*xFit*xFit)*xFit*(1-xFit)*(1-xFit))
  bin_width = energy[1]-energy[0];

  total_norm = 0
  cut_norm = 0
  for i in range(len(val)):
    total_norm += val[i]
    if (energy[i]-bin_width/2. >= emin):
      cut_norm += val[i]

  captures_per_stopped_muon = 0.609 # from AL capture studies
  RMC_gt_57_per_capture = 1.43e-5 # from literature (to overall captures)
  internalRPC_per_RPC = 0.00690; # just copy RPC value

  physics_events = POT * stopped_mu_per_POT * captures_per_stopped_muon * RMC_gt_57_per_capture
  gen_events = physics_events * cut_norm/total_norm

  if internal:
    physics_events *= internalRPC_per_RPC;
    gen_events *= internalRPC_per_RPC;

  return gen_events
  
def pot_to_livetime(pot):
    return pot / POT_per_second

if __name__ == '__main__':
  tst_1BB = livetime_to_pot(9.52e6)
  tst_2BB = livetime_to_pot(1.58e6)
  tst_rpc = rpc_normalization(3.77e19,350,1)
  print("SU2020", tst_1BB, tst_2BB)

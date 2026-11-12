# Production
Scripts and fcl for collaboration production procedures

## Samples made with the nominal tracker

The reco fcls in `JobConfig/reco` and `JobConfig/recoMC` use the Run 1A (reduced tracker) settings, and Offline uses the Run 1A tracker conditions by default. To reconstruct a sample digitized with the nominal tracker, which includes the productions made before these defaults changed, include `JobConfig/reco/run2_epilog.fcl` after the reco fcl:

```
#include "Production/JobConfig/recoMC/OnSpill.fcl"
#include "Production/JobConfig/reco/run2_epilog.fcl"
```

This restores both the nominal reco settings and the nominal tracker conditions (`Offline/TrackerConditions/fcl/run2conditions_epilog.fcl`).

To digitize or mix a sample with the nominal tracker, include `JobConfig/digitize/run2_epilog.fcl` after the digitize or mixing fcl:

```
#include "Production/JobConfig/digitize/OnSpill.fcl"
#include "Production/JobConfig/digitize/run2_epilog.fcl"
```

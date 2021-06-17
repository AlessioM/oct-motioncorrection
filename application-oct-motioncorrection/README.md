# OCT motion correction
performes a Z motion correction on an OCT volume

## notes

* volume must be indexed as vol(Z,X,Y) (i.e. vol(:,:,100) is the 100th B-scan)
* will perform motion correction only in the Z axis
* will use a circular shift (i.e. voxels moved out on top will wrap around to the bottom)
* uses parallel functions, so open a matlab pool to speed up
* depends on output of application-oct-posestimation

## usage
    
    posEstimate = octPositionEstimation(volume);
    [smooth, posDelta] = octMotionCorrection(volume, posEstimate);

see *exampleUsage.m* for more details
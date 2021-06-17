# OCT shape estimation and correction

functions that generate and apply Z displacement maps that correct
motion artefacts and shape distortions in OCT images

## usage

	dispMap = getZDisplacementMap(volume, voxelSize);
	corrected = applyZDisplacementMap(volume, dispMap)

see *test_zdispmap.m* for an example

## requirements

requires functions from the projects

* application.oct.PosEstimation
* application.oct.MotionCorrection
* util.math.Sphere

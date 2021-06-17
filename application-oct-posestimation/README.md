# retina positon estimation

Estimates the position of the retina in the OCT scan by finding the maximum brightness.
Filters the ouput using a median 1D filter in each B-scan

## usage

    posEstimate = octPositionEstimation(volume);

see estimate.m
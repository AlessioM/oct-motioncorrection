close all;
clear all;

addpath('../util-debug-logger');
addpath('../application-oct-posestimation');
ddisp('LOG_RESET');

totalGlobal = [];
totalLocal = [];
    
for octIdx = 1:8
    ddisp('loading volume %d', octIdx);
    bScans = '/mnt/optima/OCT Benchmark/OCTBenchmarkPNGs-3/BenchmarkDB_OriginalRatio/synthetic_%d/B-Scans/B-Scan_%d.png';
    bScanIdx = 0:127;
    bScanSize = size(imread(sprintf(bScans,octIdx,bScanIdx(1))));
    vol = zeros(bScanSize(1), bScanSize(2), numel(bScanIdx));

    for bi = bScanIdx
        ddisp([bi, numel(bScanIdx)], 'loading B-scan %d/%d', octIdx,bi);
        vol(:,:,bi+1) = imread(sprintf(bScans,octIdx,bScanIdx(bi+1)));
    end    
        
    for testRun = 1:2
        ddisp('adding motion artefacts for test run %d/%d', octIdx,testRun);
        maxMove = 20;
        posDeltaGroundTruthDelta = randi([-maxMove,maxMove],numel(bScanIdx),1);
        posDeltaGroundTruth = cumsum(posDeltaGroundTruthDelta);
        movedVol = vol;
        for Y = 1:numel(bScanIdx)
            ddisp([Y, numel(bScanIdx)], 'shifting B-scan %d', Y);
            movedVol(:,:,Y) = circshift(vol(:,:,Y), posDeltaGroundTruth(Y));
        end

        ddisp('perform motion correction');
        posEstimate = octPositionEstimation(movedVol);
        [~, posDelta] = octMotionCorrection(movedVol, posEstimate);

        ddisp('calculate errors');
        error = posDeltaGroundTruth + posDelta;
        rightNeighbour = circshift(posDeltaGroundTruth,1);
        rightNeighbour(1) = rightNeighbour(2);
        rightGroundTruth = posDeltaGroundTruth - rightNeighbour;

        rightNeighbour = circshift(posDelta,1);
        rightNeighbour(1) = rightNeighbour(2);
        right = posDelta - rightNeighbour;
        localError = rightGroundTruth + right;

        totalGlobal = [totalGlobal error];
        totalLocal = [totalLocal localError];

    end
end


boxplot(totalLocal');
grid on;
title(sprintf('local error, mean %5.3f, std = %5.3f',mean(totalLocal(:)), std(totalLocal(:))));

figure;
boxplot(totalGlobal');
grid on;
title(sprintf('global error, mean %5.3f, std = %5.3f',mean(totalGlobal(:)), std(totalGlobal(:))));
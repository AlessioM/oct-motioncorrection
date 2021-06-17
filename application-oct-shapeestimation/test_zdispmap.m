clear all;
close all;

addpath('../data-loader-oct-fromOctavo');
addpath('../application-oct-posestimation');
addpath('../application-oct-motioncorrection');
addpath('../util-math-sphere');
addpath('../util-oct-showcs');

addpath('../util-debug-logger');
ddisp('LOG_RESET');

samples = {'sample_1_cirrus', 'sample_2_spectralis', 'sample_3_topcon', ...
    'sample_4_nidek', 'sample_5_optovue'};
sampleIdx = 1;

ddisp('loading oct: %s ', samples{sampleIdx});
sampleOct = loadFromOctavo(['../data-loader-oct-fromOctavo/' samples{sampleIdx} '/index.csv']);

ddisp('calculate displacement map');
dispMap = getZDisplacementMap(sampleOct.volume, sampleOct.voxelSize);

ddisp('display result');
imagesc(dispMap);
xlabel('A-scan (i.e. X coordinate)');
ylabel('B-scan (i.e. Y coordinate)');
title('A-scan Z axis displacement map');

ddisp('apply to volume');
corrected = applyZDisplacementMap(sampleOct.volume, dispMap);

ddisp('display volumes');
showcs(sampleOct.volume);
showcs(corrected);

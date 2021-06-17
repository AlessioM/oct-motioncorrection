clear all;
close all;

if matlabpool('size') == 0
    matlabpool(8);
end


addpath('../data-loader-oct-fromOctavo');
addpath('../util-debug-logger');
ddisp('LOG_RESET');

samples = {'sample_1_cirrus', 'sample_2_spectralis', 'sample_3_topcon', ...
    'sample_4_nidek', 'sample_5_optovue'};
sampleIdx = 5;

ddisp('loading oct: %s ', samples{sampleIdx});
sampleOct = loadFromOctavo(['../data-loader-oct-fromOctavo/' samples{sampleIdx} '/index.csv']);

ddisp('estimate positon');
posEstimate = octPositionEstimation(sampleOct.volume);

%%
idx = 1;
ddisp('display result');
surf(posEstimate);
figure;
imshow(sampleOct.volume(:,:,idx));
hold on;
plot(posEstimate(:,idx));


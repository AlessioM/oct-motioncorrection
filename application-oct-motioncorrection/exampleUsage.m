%clear all;
close all;

if matlabpool('size') == 0
    matlabpool(8);
end

addpath('../data-loader-oct-fromOctavo');
addpath('../application-oct-posestimation');
addpath('../util-debug-logger');
ddisp('LOG_RESET');

samples = {'sample_1_cirrus', 'sample_2_spectralis', 'sample_3_topcon', ...
    'sample_4_nidek', 'sample_5_optovue'};
sampleIdx = 1;

ddisp('loading oct: %s ', samples{sampleIdx});
sampleOct = loadFromOctavo(['../data-loader-oct-fromOctavo/' samples{sampleIdx} '/index.csv']);

ddisp('calculate position estimation');
posEstimate = octPositionEstimation(sampleOct.volume);

ddisp('perform motion correction');
[smooth, posDelta] = octMotionCorrection(sampleOct.volume, posEstimate);

rpe = sampleOct.segmentation.RPE;
ilm = sampleOct.segmentation.ILM;



ddisp('plot example');
figure;
xIdx = 250;
subplot(1,2,1); 
imshow(squeeze(sampleOct.volume(:,xIdx,:)));
hold on;
plot(rpe(xIdx,:), 'r');
plot(ilm(xIdx,:), 'g');
hold off;
axis square
title(sprintf('original YZ scan %03d',xIdx));

subplot(1,2,2); 
imshow(squeeze(smooth(:,xIdx,:)));
hold on;
plot(rpe(xIdx,:) + posDelta', 'r');
plot(ilm(xIdx,:) + posDelta', 'g');
hold off;
axis square
title(sprintf('flat YZ scan %03d',xIdx));

ddisp('plot segmentation');
offsets = repmat(posDelta',size(sampleOct.volume, 2),1);


figure; 
surf(1-rpe - offsets);
hold on;
ilmFlat = 1-ilm-offsets;
surf(ilmFlat);
ilmFlat(1:end-10,:) = NaN;
h = surf(ilmFlat);
set(h, 'EdgeColor', 'white')
hold off;
title('flattened');

figure;
surf(1-rpe);
hold on;
ilm = 1-ilm;
surf(ilm);
ilm(1:1:end-10,:) = NaN;
h = surf(ilm);
set(h, 'EdgeColor', 'white')
hold off;
title('original');

ddisp('finished');
function [ smooth, zOffsets ] = octMotionCorrection( volume, posEstimate, varargin )
%OCTMOTIONCORRECTION perform motion correction alog Z-axis
%   Detailed explanation goes here

    p = inputParser;
    p.addOptional('maxHWindowSize', 40);
    p.addOptional('minHWindowSize', 20);
    p.addOptional('numRandomSamples', 20);         

    p.parse(varargin{:});

    maxHWindowSize = p.Results.maxHWindowSize;
    minHWindowSize = p.Results.minHWindowSize;
    
    if minHWindowSize > maxHWindowSize
        error('maxHWindowSize must not be smaller than minHWindowSize');
    end
                
    numRandomSamples = p.Results.numRandomSamples;
    
    numberOfBscans = size(volume,3);
    
    if minHWindowSize > numberOfBscans;
        minHWindowSize = 1;
    end
    
    sizeX = size(volume,2);    
    
    relPos      = zeros(numberOfBscans, 2*maxHWindowSize + 1); 
    sampleCount = zeros(numberOfBscans, 2*maxHWindowSize + 1);

    parfor Y = minHWindowSize+1:numberOfBscans - minHWindowSize
        
        % maximum possible window on this B-scan
        maxPossibleYHWindowSize = min([Y-1 numberOfBscans-Y maxHWindowSize]);        
        
        for n = 1:numRandomSamples        
            
            % random A-scan on this B-scan
            X = randi([minHWindowSize + 1, sizeX - minHWindowSize],1);

            % maximum possible window for this A-scan (only in X direction)
            maxPossibleXHWindowSize = min([X-1 sizeX-X maxHWindowSize]);
                        
            % actual window size is the maximum possible
            hWindowSize = min(maxPossibleYHWindowSize, maxPossibleXHWindowSize);
            windowSize = 2*hWindowSize+1;
            
            % create window in XZ plane
            windowXZ = squeeze(volume(:,X-hWindowSize:X+hWindowSize,Y));

            % create window in YZ plane
            windowYZ = squeeze(volume(:,X,Y-hWindowSize:Y+hWindowSize));

            % unrotate windows
            windowXZrot = unRotateWindow(double(windowXZ), posEstimate(X-hWindowSize:X+hWindowSize,Y)', hWindowSize);
            windowYZrot = unRotateWindow(double(windowYZ), posEstimate(X,Y-hWindowSize:Y+hWindowSize), hWindowSize);

            % estimate local translation
            shifts          = zeros(1, 2*maxHWindowSize + 1);
            sampleCountInc  = zeros(1, 2*maxHWindowSize + 1);   
            
            for i = 1:windowSize
                % calculating cross correlation
                [c lags] = xcorr(windowXZrot(:,i), windowYZrot(:,i));
                [~, li] = max(c);
                
                idx = maxHWindowSize + 1 - hWindowSize + i - 1;
                shifts(idx) = lags(li);
                sampleCountInc(idx) = 1;
            end

            % update relative positions
            relPos(Y,:)      = relPos(Y,:) + shifts;        
            sampleCount(Y,:) = sampleCount(Y,:) + sampleCountInc;
        end

    end    
    
    % results in NaN for sampleCount == 0
    relPos = relPos ./ sampleCount;
    
    % estimate relative positions
    zOffsets = relPos;
    for y = -maxHWindowSize:maxHWindowSize
        zOffsets(:,y+maxHWindowSize+1) = circshift(squeeze(relPos(:,y+maxHWindowSize+1)),y);
    end
    zOffsets = round(nanmean(zOffsets,2));    
    
    % correct the volume    
    smooth = volume;
    for Y = 1:numberOfBscans
        if ~isnan(zOffsets(Y))
            smooth(:,:,Y) = circshift(volume(:,:,Y), zOffsets(Y));
        end
    end
    
end

function [ scaledWindow ] = unRotateWindow( window, posEstimate, hWindowSize )
%UNROTATEWINDOW esitmates the oct orientation using the center of mass
%   of each A-scan and un-rotates it
%   result will be of same size as window and in range [0:1]
%   middle column will not be moved

    scaledWindow = (window - min(window(:))) ./ range(window(:));
    
    x = 1:size(window,2);
    p = polyfit(x,posEstimate,1);
    y = x .* p(1) + p(2);

    
    yShift = round(y(hWindowSize+1)-y);    
    for x = 1:size(scaledWindow,2)           
        scaledWindow(:,x) = circshift(squeeze(scaledWindow(:,x)), yShift(x));
    end

end


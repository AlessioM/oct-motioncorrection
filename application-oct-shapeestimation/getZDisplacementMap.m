function [ dispMap ] = getZDisplacementMap( volume, voxelSize, varargin )
%GETZDISPLACEMENTMAP calculate a displacement map that corrects shape and
%motion artefacts

    p = inputParser;
    p.addOptional('posEstimate', false);
    p.addOptional('doMotionCorrection', true);
    p.addOptional('doTiltCorrection', true);         

    p.parse(varargin{:});

    posEstimate = p.Results.posEstimate;
    doMotionCorrection = p.Results.doMotionCorrection;
    doTiltCorrection = p.Results.doTiltCorrection;
    
    if ~posEstimate        
        posEstimate = octPositionEstimation(volume);        
    end

    %do not perform motion correction if requested
    if doMotionCorrection
        [smooth, posDelta] = octMotionCorrection(volume, posEstimate);               
    else
        posDelta = zeros(size(volume,3), 1);        
    end
    
    posDelta = repmat(posDelta',size(volume,2),1);

    if doTiltCorrection
        X = (1:size(smooth,2)) .* voxelSize(2);
        Y = (1:size(smooth,3)) .* voxelSize(3);

        [Xm Ym] = meshgrid(X,Y);

        p = (posEstimate .*  voxelSize(1))';

        numModels = 20;
        numTry = 10;
        
        center = zeros(numTry,3);
        radius = zeros(numTry,1);
        ransacFailed = false;
        for i = 1:numModels
            if ~ransacFailed
                found = false;
                for j = 1:numTry
                    if ~found
                        [c, r] = sphereRansac(Xm(:), Ym(:), p(:), 'numTry', 1000, 'maxModelDist', 100);                
                        ZbottomRansac = sphereHeightMap(X,Y,c,r, 0);
                        if nnz(isnan(ZbottomRansac(:))) == 0
                            found = true;                    
                        end
                    end
                end
                if found
                    center(i, :) = c;
                    radius(i) = r;                    
                else
                    ransacFailed = true;                
                end            
            end
        end
         
        if ~ransacFailed
            center = median(center);
            radius = median(radius);
            
            ZbottomRansac = sphereHeightMap(X,Y,center,radius, 0);
            
            Xmean = size(volume,2) / 2 * voxelSize(2);
            Ymean = size(volume,3) / 2 * voxelSize(3);
            ZbottomMean = sphereHeightMap(X,Y,[Xmean, Ymean, center(3)], radius, 0);

            shapeDelta = (ZbottomRansac - ZbottomMean) ./ voxelSize(1);

            dispMap = round(shapeDelta + posDelta');
        else
            dispMap = round(posDelta');
        end
    else
        dispMap = round(posDelta');
    end
    
    dispMap = dispMap - mean(dispMap(:)) + ...
        size(volume,1)/2 - mean(posEstimate(:));
    dispMap = double(round(dispMap));
end


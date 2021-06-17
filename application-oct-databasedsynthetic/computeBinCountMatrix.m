function [ aScans, counts ] = computeBinCountMatrix( scanList, loadingFunction, maxThickness, maxSize, numThetaGroups, rhoGroupSize )
%COMPUTEBINCOUNTMATRIX
%   scanList            cell array of filenames that are passed to loadingFunction
%   loadingFunction     function handle to a function that loads the oct,
%                       example: @loadFromOctavo
%   maxThickness        maximum thickness (ILM-RPE) that is considered
%                       unit: pixels
%   maxSize             maximum size (diagonal) of an oct in µm
%   numThetaGroups      abount of circular subdivitions
%   rhoGroupSize        radius delta of concectric bin circles in µm

    %calculate the maximum number of bins possible
    maxNumBin = floor((maxSize / 2) / rhoGroupSize * numThetaGroups) + 1;
    
    %create result arrays
    %the +100 are for the 50 pixels above the ILM and below the RPE
    aScans = zeros(maxThickness,maxNumBin,maxThickness+100);
    counts = zeros(maxThickness,maxNumBin);
    
    numScan = numel(scanList);
    
    ddisp('looping over %d scans', numScan);
    for si = 1:numScan
        try 
            ddisp('loading %d/%d: %s', si,numScan, scanList{si});
            oct = loadingFunction(scanList{si});
            
            %check if loading was succesfull
            if isempty(oct)
                throw(MException('Synthetic:notLoaded', 'could not load'));
            end
            
            if ~isfield(oct, 'segmentation')
                throw(MException('Synthetic:noSegmentation', 'scan has no segmentation'));
            end
            
            if ~isfield(oct.segmentation , 'ILM')
                throw(MException('Synthetic:noILM', 'no ILM segmentation found'));
            end
            
            if ~isfield(oct.segmentation, 'RPE')
                throw(MException('Synthetic:RPE', 'no RPE segmentation found'));
            end
            
            if ~isfield(oct, 'maculaPositon')
                ddisp('guessing macula position');
                oct.maculaPosition = [0.5 0.5];                
            end
            
            if ~isfield(oct, 'eye')
               ddisp('guessing eye');
                oct.eye = 'OS';
            end                                 
            
            rpe = oct.segmentation.RPE;
            ilm = oct.segmentation.ILM;
            vol = oct.volume;
            volSize = size(vol);
                        
            if volSize(1) < maxThickness + 100
                ddisp('padding volume');
                paddingTop    = floor(((maxThickness + 100) - volSize(1)) / 2);
                paddingBottom =  ceil(((maxThickness + 100) - volSize(1)) / 2);
                
                topSlice = repmat(vol(1,:,:), [paddingTop 1 1]);
                bottomSlice = repmat(vol(end,:,:), [paddingBottom 1 1]);
                
                vol = cat(1, topSlice, vol, bottomSlice);
                volSize = size(vol);
                rpe = rpe + paddingTop;
                ilm = ilm + paddingTop;
                
            end
            
            ddisp('flattening volume');
            flat = applyZDisplacementMap(vol, maxThickness - 150 - rpe');
            
            ddisp('cut to max thickness');
            flat = flat(end-(maxThickness+100)+1:end,:,:);
            
            ddisp('calculating thickness');            
            rpe(rpe < 0) = NaN;
            ilm(ilm < 0) = NaN;    
            thickness = rpe-ilm;
            
            ddisp('create bin image');            
            bin = getBinImage(volSize, strcmp(oct.eye, 'OS'), oct.voxelSize, oct.maculaPosition, numThetaGroups, rhoGroupSize);
            
            ddisp('increment count bins and mean aScans');
            for x = 1:volSize(2)
                for y = 1:volSize(3)
                    if ~isnan(thickness(x,y)) && thickness(x,y) > 0 && thickness(x,y) < maxThickness
                        counts(thickness(x,y), bin(x,y))    = counts(thickness(x,y), bin(x,y)) + 1;
                        aScans(thickness(x,y), bin(x,y),:)  = squeeze(aScans(thickness(x,y), bin(x,y),:)) + double(squeeze(flat(:,x,y)));                        
                    end
                end
            end
        catch err
            ddisp('ERROR while processing %d/%d: %s (line %d)', si,numScan, err.message, err.stack(1).line);
        end
    end

end



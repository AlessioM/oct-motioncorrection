function [ volume ] = generateVolume( thicknessMap, maculaPosition, voxelSize, aScans, counts, numThetaGroups, rhoGroupSize, r )

    ddisp('creating empty volume');
    volume = zeros(size(aScans, 3), size(thicknessMap,1), size(thicknessMap,2), 'uint8');   
    volSize = size(volume);                
    numBin = size(counts,2);

    ddisp('getting bin image');
    bin = getBinImage(volSize, 1, voxelSize, maculaPosition, numThetaGroups, rhoGroupSize);
    
    ddisp('filling synthetic volume');
    for x = 1:size(volume,2)
        ddisp('at YZ slice %d', x);
        for y = 1:size(volume,3)
            [xM,yM]=meshgrid(-(x-1):(volSize(2)-x),-(y-1):(volSize(3)-y));
            c_mask=((xM.^2+yM.^2)<=r^2);
            binHits = histc(bin(c_mask'),1:numBin);

            a = zeros(size(aScans,3),1);
            t = min(thicknessMap(x,y), size(aScans,3));
            
            totalBinHits = 0;
            for b = 1:numBin
                if counts(t,b) > 0 && binHits(b) > 0
                    a = a + squeeze(aScans(t,b,:)) ./ counts(t,b) .* binHits(b);
                    totalBinHits = totalBinHits + binHits(b);
                end
            end
            a = a ./ totalBinHits;

            volume(:,x,y) = a;        
        end
    end

end


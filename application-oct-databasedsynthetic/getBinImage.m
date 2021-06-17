function [ bin ] = getBinImage( volSize, isLeft, voxelSize, maculaPosition, numThetaGroups, rhoGroupSize)

        if isLeft
            x = (1:volSize(2)) -    (maculaPosition(1) * volSize(2));
        else
            x = (volSize(2):-1:1) - ((1-maculaPosition(1)) * volSize(2));
        end                
        x = x .* voxelSize(2);
        y = ((1:volSize(3)) - maculaPosition(2) * volSize(3)) * voxelSize(3);                
        
        [X,Y] = meshgrid(x,y);
        [THETA,RHO] = cart2pol(X,Y);
        
        t = (floor(mod(THETA,2*pi) ./ (2*pi/numThetaGroups)));
        r = floor(RHO ./ rhoGroupSize);

        bin = (r * numThetaGroups + t) + 2;
        bin(RHO < (rhoGroupSize/2)) = 1;
    
        bin = bin';
end


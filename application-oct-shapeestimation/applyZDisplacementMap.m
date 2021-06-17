function [ correctedVolume ] = applyZDisplacementMap( volume, displacementMap )
%APPLYZDISPLACEMENTMAP apply the displacement map to the volume
%   resulting volume has same size as volume, voxels are wrapped on the Z axis

    correctedVolume = volume;
    for Xs = 1:size(correctedVolume,2)
        for Ys = 1:size(correctedVolume,3)
            correctedVolume(:,Xs,Ys) = circshift(correctedVolume(:,Xs,Ys), displacementMap(Ys,Xs));
        end
    end

end


function [ posEstimate ] = octPositionEstimation( vol, medianSize )
%OCTPOSITIONESTIMATION simple estimate of the retina position
%   assumes volume to be indexed as Z,X,Y
%   assumes primary scan direction to be X
    
    if nargin < 2
        medianSize = 30;
    end       

%     [~, volMax] = max(double(vol),[],1);
%     volMax = squeeze(volMax);
% 
%     parfor Y = 1:size(vol,3)
%         volMax(:,Y) = medfilt1(volMax(:,Y),medianSize);
%     end
% 
%     posEstimate = volMax;

    posEstimate = zeros(size(vol,2), size(vol,3));
    
    for Y = 1:size(vol,3)        
        parfor X = 1:size(vol,2)
            col = double(vol(:,X,Y));
            colMed = medfilt1(col, medianSize);
            [height, pos] = findpeaks(colMed, 'SORTSTR', 'descend', 'MINPEAKDISTANCE', ceil(numel(col) * 0.05));
            
            if(numel(pos) >= 2)
                posEstimate(X,Y) = max(pos(1:2));                
            elseif(numel(pos) == 1)
                posEstimate(X,Y) = pos(1);
            else
                [~, posEstimate(X,Y)] = max(col);
            end            
            
        end
        
        posEstimate(:,Y) = medfilt1(posEstimate(:,Y),medianSize);
    end    

end


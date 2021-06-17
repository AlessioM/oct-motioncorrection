function [ total ] = getSyntheticThicknessMap( p, voxelSize, volumeSize)


        %parameters:
        % 1 | both: correlation
        % 2 | outer: sigma X im µm
        % 3 | outer: sigma Y im µm
        % 4 | both: mu X in % of scan width
        % 5 | both: mu Y in % of scan height
        % 6 | outer: scale in µm
        % 7 | inner: sigma scale percent of sigma outer
        % 8 | inner: scale in µm

        % 9 | thikness offset in µm
        % 10 | thikness X gain in µm per mm
        % 11 | thikness Y gain in µm per mm
        
    if isempty(p)
        p = [
            0       -0.99999    0.99999     %  1 both: correlation
            1800    1500        2500        %  2 outer: sigma X im µm
            1800    1500        2500        %  3 outer: sigma Y im µm
            0.5     0.1         0.9         %  4 both: mu X in % of scan width
            0.5     0.1         0.9         %  5 both: mu Y in % of scan height
            70      50          200         %  6 outer: scale in µm       
            0.2     0           1           %  7 inner: scale of sigma
            -150    -300        0        %  8 inner: scale in µm       

            250     100         500         %  9 thikness offset in µm
            0       -5          5           % 10 thikness X gain in µm per mm
            3       -5          5           % 11 thikness Y gain in µm per mm
            0    	0           0           % 12 number of additional gaussians
        ]; 
    end
    
    X = 1:volumeSize(2);
    Y = 1:volumeSize(3);
    
    % central 2D gaussian
    correlationOuter    = p(1);
    sigmasOuter         = [p(3) / voxelSize(3)      p(2) / voxelSize(2)];
    muOuter             = [p(5) * volumeSize(3)     p(4) * volumeSize(2) ];
    scaleOuter          = p(6)  / voxelSize(1);
    
    sigmasInner         = sigmasOuter .* p(7);
    scaleInner          = p(8)  / voxelSize(1);
    

    FOuter = get2Dgauss(Y,X,muOuter,sigmasOuter,correlationOuter);
    FOuter = FOuter ./ max(FOuter(:)) * scaleOuter;

    FInner = get2Dgauss(Y,X,muOuter,sigmasInner,correlationOuter);
    FInner = FInner ./ max(FInner(:)) * scaleInner;
    
    %linear offsets
    d0                  = p(9)  / voxelSize(1);
    deltas              = [ p(11) / voxelSize(1) / 1000 * voxelSize(3) 
                            p(10) / voxelSize(1) / 1000 * voxelSize(2)];
                                                
    [Xm Ym] = meshgrid(X,Y);
    FLinear = d0 + Xm * deltas(2) + Ym * deltas(1);
    
    total = FOuter + FInner + FLinear;
    
    total = total';
end


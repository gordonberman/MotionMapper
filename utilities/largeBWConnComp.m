function CC = largeBWConnComp(x,minLength,vals,minVal)
%returns a structure containing only 1d connceted components above a given
%size (output structure is identical to bwconncomp)
    
    CC = bwconncomp(x);
    lengths = zeros(CC.NumObjects,1);
    for i=1:CC.NumObjects
        lengths(i) = length(CC.PixelIdxList{i});
    end
    
    idx = lengths >= minLength;
    
    CC.NumObjects = sum(idx);
    CC.PixelIdxList = CC.PixelIdxList(idx);
    
    if nargin > 3
        
        maxVals = zeros(CC.NumObjects,1);
        for i=1:CC.NumObjects
            maxVals(i) = max(vals(CC.PixelIdxList{i}));
        end
        
        CC.PixelIdxList = CC.PixelIdxList(maxVals >= minVal);
        CC.NumObjects = sum(maxVals >= minVal);
        
    end
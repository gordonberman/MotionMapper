function [watershedRegions,v,obj,pRest] = findWatershedRegions(all_z,...
                                xx,LL,medianLength,pThreshold,minRest,obj)



    if nargin < 4 || isempty(medianLength)
        medianLength = 1;
    end
    
    if nargin < 5 || isempty(pThreshold)
        pThreshold = [.67 .33];
    end
    
    if nargin < 6 || isempty(minRest)
        minRest = 5;
    end
    
    
    restLength = 5;
    dt = .01;
    numGMM = 2;
    numToTest = 50000;
    N = length(all_z(:,1));
    
    smooth_z = all_z;
    if medianLength > 0
        smooth_z(:,1) = medfilt1(all_z(:,1),medianLength);
        smooth_z(:,2) = medfilt1(all_z(:,2),medianLength);
    end
    
    vx = [0;diff(smooth_z(:,1))]./dt;
    vy = [0;diff(smooth_z(:,2))]./dt;
    v = sqrt(vx.^2+vy.^2);
    
    if nargin < 8 || isempty(obj)
        figure
        obj = gmixPlot(sampleFromMatrix(log10(v(v>0)),numToTest),numGMM,[],200,[],true,[],[],3);
        xlabel('log_{10} velocity','fontsize',16,'fontweight','bold')
        ylabel('PDF','fontsize',16,'fontweight','bold')
        set(gca,'fontsize',14,'fontweight','bold')
        drawnow;
    end
    
    [~,maxIdx] = max(obj.mu);
    minVal = min(obj.mu);
    posts = posterior(obj,log(v)./log(10));
    posts(v==0,maxIdx) = 0;
    posts(v<minVal,maxIdx) = 0;
    pRest = 1 - posts(:,maxIdx);
    
    
    vals = round((smooth_z + max(xx))*length(xx)/(2*max(xx)));
    vals(vals<1) = 1;
    vals(vals>length(xx)) = length(xx);
    
    
    watershedValues = zeros(N,1);
    for i=1:N
        watershedValues(i) = diag(LL(vals(i,2),vals(i,1)));
    end
    diffValues = abs([0;diff(watershedValues)]) == 0;
    
    L = max(LL(:));
    if length(pThreshold) == 1
        
        CC = largeBWConnComp(pRest > pThreshold & diffValues,minRest);
        
    else
        
        minVal = min(pThreshold);
        maxVal = max(pThreshold);
        
        CC = largeBWConnComp(pRest > minVal & diffValues,minRest);
        maxInRanges = zeros(CC.NumObjects,1);
        for i=1:CC.NumObjects
            maxInRanges(i) = max(pRest(CC.PixelIdxList{i}));
        end
        
        CC.NumObjects = sum(maxInRanges >= maxVal);
        CC.PixelIdxList = CC.PixelIdxList(maxInRanges >= maxVal);
        
    end
    
    segmentAssignments = zeros(size(CC.PixelIdxList));
    watershedRegions = zeros(N,1);
    for i=1:CC.NumObjects
        segmentAssignments(i) = mode(watershedValues(CC.PixelIdxList{i}));
        watershedRegions(CC.PixelIdxList{i}) = segmentAssignments(i);
    end
    
    for i=1:L
        CC = largeBWConnComp(watershedValues == i,restLength);
        for j=1:length(CC.PixelIdxList)
            watershedRegions(CC.PixelIdxList{j}) = i;
        end
    end
    
        
  
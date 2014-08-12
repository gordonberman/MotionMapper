function [Xs,Ys,angles,areas,svdskips] = ...
    align_subroutine_parallel_avi(grouping,initialPhi,segmentationOptions,nDigits,file_path,...
    image_path,readout,processorNum,asymThreshold,initialArea,vidObj,fid,areanorm,initialImage)
%align_subroutine_parallel_avi is a subroutine used within
%alignImages_Radon_parallel_avi in order to parallelize properly
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University



warning off MATLAB:audiovideo:aviread:FunctionToBeRemoved;
L = length(grouping);
Xs = zeros(L,1);
Ys = zeros(L,1);
angles = zeros(L,1);
areas = zeros(L,1);
svdskips = zeros(L,1);
vidChunk = read(vidObj,[grouping(1) grouping(end)]);

open(image_path);
writeVideo(image_path,initialImage);


dilateSize = segmentationOptions.dilateSize;
cannyParameter = segmentationOptions.cannyParameter;
imageThreshold = segmentationOptions.imageThreshold;
spacing = segmentationOptions.spacing;
pixelTol = segmentationOptions.pixelTol;
basis = segmentationOptions.referenceImage;
maxAreaDifference = segmentationOptions.maxAreaDifference;
segmentationOff = segmentationOptions.segmentationOff;
symLine = segmentationOptions.symLine;
minRangeValue = segmentationOptions.minRangeValue;
maxRangeValue = segmentationOptions.maxRangeValue;

s = size(basis);
currentMinArea = ceil(initialArea*(1-maxAreaDifference));

for j=2:L
    
    if mod(j,readout) == 0
        fprintf(1,'\t Processor #%2i, Image #%7i of %7i\n',processorNum,j,L);
    end
    
    
    
    k = grouping(j);
    nn = nDigits - 1 - floor(log(k+1e-10)/log(10));
    zzs  = repmat('0',1,nn);
    
    originalImage = squeeze(vidChunk(:,:,1,j));
    sCurrent = size(originalImage);
    
    if sCurrent(1) < s(1) || sCurrent(2) < s(2)
        zz = uint8(zeros(s)+255);
        zz(1:sCurrent(1),1:sCurrent(2)) = originalImage;
        originalImage = zz;
    end
    if ~segmentationOff
        imageOut = segmentImage_combo(originalImage,dilateSize,cannyParameter,...
            imageThreshold,[],[],currentMinArea,true);
        imageOut = rescaleImage(imageOut,areanorm);
    else
        imageOut = originalImage;
        imageOut = rescaleImage(imageOut,areanorm);
    end
    
    
    
    areas(j) = sum(imageOut(:) ~= 0);
    currentMinArea = ceil((1-maxAreaDifference)*areas(j));
    
    
    imageOut2 = imageOut;
    imageOut2(imageOut2 < asymThreshold) = 0;
    if max(imageOut2(:)) ~= 0
        [angles(j),Xs(j),Ys(j),~,~,loopImage] = ...
            alignTwoImages(basis,imageOut2,initialPhi,spacing,pixelTol,false,imageOut);
        
        
        b = loopImage;
        b(b > asymThreshold) = 0;
        
        if minRangeValue > 1
            b(1:minRangeValue-1,:) = 0;
        end
        
        if maxRangeValue < length(basis(:,1))
            b(maxRangeValue+1:end,:) = 0;
        end
        
        q = sum(b) ./ sum(b(:));
        
        asymValue = symLine - sum(q.*(1:s(1)));
        if asymValue < 0
            
            initialPhi = mod(initialPhi+180,360);
            [tempAngle,tempX,tempY,~,~,tempImage] = ...
                alignTwoImages(basis,imageOut2,initialPhi,spacing,pixelTol,false,imageOut);
            
            b = tempImage;
            b(b > asymThreshold) = 0;
            if minRangeValue > 1
                b(1:minRangeValue-1,:) = 0;
            end
            if maxRangeValue < length(basis(:,1))
                b(maxRangeValue+1:end,:) = 0;
            end
            
            q = sum(b) ./ sum(b(:));
            asymValue2 = symLine - sum(q.*(1:s(1)));
            
            if asymValue2 > asymValue
                angles(j) = tempAngle;
                Xs(j) = tempX;
                Ys(j) = tempY;
                loopImage = tempImage;
            end
        end
        
        
        
        
        initialPhi = angles(j);
        svdskips(j) = 0;
        writeVideo(image_path,loopImage);
        
    else
        
        angles(j) = angles(j-1);
        svdskips(j) = 1;
        loopImage = uint8(zeros(size(imageOut2)));
        writeVideo(image_path,loopImage);
        
    end
    
end

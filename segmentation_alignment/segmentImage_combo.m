function [imageOut,mask] = segmentImage_combo(image,dilateSize,cannyParameter,threshold,alpha,maxIter,minimumArea,chanVeseOff)
%segmentImage_combo segments an image from its background
%
%   Input variables:
%
%       image -> image to be analyzed
%       dilateSize -> initial dilation size for image segmentation
%       cannyParameter -> parameter for Canny edge detection
%       threshold -> threshold for image segmentation
%       minimumArea -> minimum allowed area for segmented image
%       alpha, maxIter, chanVeseOff -> not used in this version of the code
%
%
%   Output variables:
%
%       imageOut -> segmented image
%       mask -> binary mask that is 'true' for non-zero pixels in imageOut
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University


    if nargin < 2 || isempty(dilateSize) == 1
        dilateSize = 3;
    end
    
    if nargin < 3 || isempty(cannyParameter) == 1
        cannyParameter = .1;
    end
    
    if nargin < 4 || isempty(threshold) == 1
        threshold = 0;
    end
    
    if nargin < 5 || isempty(alpha) == 1
        alpha = .5;
    end
    
    if nargin < 6 || isempty(maxIter) == 1
        maxIter = 10;
    end
    
    if nargin < 7 || isempty(minimumArea) == 1
        minimumArea = 3500;
    end
    
    if nargin < 8 || isempty(chanVeseOff)
        chanVeseOff = true;
    else
        chanVeseOff = true;
    end
    
    
    image(image > 255 - threshold) = 255;
    
    E = edge(image,'canny',cannyParameter,'nothinning');
    se = strel('square',dilateSize);
    E2 = imdilate(E,se);
    mask = imfill(E2,'holes');
    
    CC = bwconncomp(mask,4);
    if length(CC.PixelIdxList) > 1
        lengths = zeros(1,length(CC.PixelIdxList));
        for j=1:length(lengths)
            lengths(j) = length(CC.PixelIdxList{j});
        end
        [~,idx] = max(lengths);
        temp = mask;
        temp(:) = 0;
        temp(CC.PixelIdxList{idx}) = 1;
        mask = temp;
    end
    
    
    while sum(mask(:)) < minimumArea && dilateSize <= 6 && cannyParameter > 0
        
        dilateSize = dilateSize + 1;
        cannyParameter = .1;
        se = strel('square',dilateSize);
        E2 = imdilate(E,se);
        mask = imfill(E2,'holes');
        
        CC = bwconncomp(mask,4);
        if length(CC.PixelIdxList) > 1
            lengths = zeros(1,length(CC.PixelIdxList));
            for j=1:length(lengths)
                lengths(j) = length(CC.PixelIdxList{j});
            end
            [~,idx] = max(lengths);
            temp = mask;
            temp(:) = 0;
            temp(CC.PixelIdxList{idx}) = 1;
            mask = temp;
        end
        
        
    end
    
    
    if mean(image(:)) < 100
        imageOut = immultiply(mask,image);
    else
        imageOut = immultiply(mask,imcomplement(image));
    end
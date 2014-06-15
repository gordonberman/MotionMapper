function projections = find_PCA_projections(files,coeffs,meanValues,...
                            pixels,thetas,numProjections,scale,batchSize)
%find_PCA_projections finds the projection of a set of images onto
%postural eigenmodes (called by findProjections.m)
%
%   Input variables:
%
%       filePath -> directory containing aligned .tiff files
%       coeffs -> postural eignmodes (L x (M<L) array)
%       meanValues -> mean value for each of the pixels
%       pixels -> radon-transform space pixels to use (Lx1 or 1xL array)
%       thetas -> angles used in Radon transform
%       numProjections -> # of projections to find
%       scale -> image scaling factor
%       batchSize -> # of files to process at once
%
%
%   Output variables:
%
%       projections -> N x d array of projection values
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University


    N = length(files);
    if N < batchSize
        batchSize = N;
    end
    files = files(randperm(N));
    num = ceil(N/batchSize);
    L = length(pixels);
    
    if nargin < 6 || isempty(numProjections)
        numProjections = length(coeffs(1,:));
    end
    coeffs = coeffs(:,1:numProjections);
    
    testImage = imread(files{1});
    s = size(testImage);
    nX = round(s(1)/scale);
    nY = round(s(2)/scale);
    s = [nX nY];
    
    sM = size(meanValues);
    if sM(1) == 1
        meanValues = meanValues';
    end
    
    
    projections = zeros(N,numProjections);
    tempData = zeros(batchSize,L);
    currentImage = 0;
    for i=1:num
        fprintf(1,'Processing Batch #%5i of %5i\n',i,num);
        
        tempData(:) = 0;
        if i == num
            maxJ = N - currentImage;
            tempData = tempData(1:maxJ,:);
        else
            maxJ = batchSize;
        end
    
        
        parfor j=1:maxJ
            a = imresize(imread(files{currentImage+j}),s);
            lowVal = min(a(a>0));
            highVal = max(a(a>0));
            a = (a - lowVal) / (highVal - lowVal);
            
            R = radon(a,thetas);
            tempData(j,:) = R(pixels) - meanValues;
        end
        
        projections((1:maxJ) + batchSize*(i-1),:) = tempData*coeffs;
        currentImage = currentImage +  maxJ;
    end
    
    
    
    
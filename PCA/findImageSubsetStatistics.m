function [meanRadon,stdRadon] = findImageSubsetStatistics(alignedImageDirectory,numToTest,thetas,scale)
%findImageSubsetStatistics finds the Radon-transform space mean and
%standard deviations for all of the files in a directory
%
%   Input variables:
%
%       alignedImageDirectory -> directory containing aligned .tiff files
%       numToTest -> number of images from which to calculate values
%       thetas -> angles used in Radon transform
%       scale -> image scaling factor%
%
%   Output variable2:
%
%       meanRadon -> mean values of pixels in Radon-transform space
%       stdRadon -> standard deviations of pixels in Radon-transform space
%
% (C) Gordon J. Berman, 2014
%     Princeton University


    readout = 500;

    files = findAllImagesInFolders(alignedImageDirectory,'tiff');
    N = length(files);
    if nargin < 2 || isempty(numToTest)
        numToTest = N;
    end 
    
    if numToTest > N
        idx = 1:N;
        numToTest = N;
    else
        idx = randperm(N,numToTest);
    end
    filesToTest = files(idx);
    
    testImage = imread(filesToTest{1});
    s = size(testImage);
    nX = round(s(1)/scale);
    nY = round(s(2)/scale);
    s = [nX nY];
    testImage = radon(imresize(testImage,s),thetas);
    sR = size(testImage);
    
    
    radonImages = zeros(sR(1),sR(2),numToTest);
    fprintf(1,'Calculating Image Radon Transforms\n');
    parfor i=1:numToTest
        
        if mod(i,readout) == 0
            fprintf(1,'\t Image #%7i out of %7i\n',i,numToTest);
        end
        
        image = imread(filesToTest{i});
        a = imresize(image,s);
        lowVal = min(a(a>0));
        highVal = max(a(a>0));
        a = (a - lowVal) / (highVal - lowVal);
        
        radonImages(:,:,i) = radon(a,thetas);
        
    end
    
    
    
    
    meanRadon = zeros(sR);
    stdRadon = zeros(sR);
    for i=1:sR(1)
        for j=1:sR(2)
            meanRadon(i,j) = mean(squeeze(radonImages(i,j,:)));
            stdRadon(i,j) = std(squeeze(radonImages(i,j,:)));
        end
    end
    
    
    
    
    
    
    
    
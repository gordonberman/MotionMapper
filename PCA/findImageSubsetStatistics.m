function [meanRadon,stdRadon,vidObjs] = findImageSubsetStatistics(alignedImageDirectory,numToTest,thetas,scale)
%findImageSubsetStatistics finds the Radon-transform space mean and
%standard deviations for all of the files in a directory
%
%   Input variables:
%
%       alignedImageDirectory -> directory containing aligned .avi files
%       numToTest -> number of images from which to calculate values
%       thetas -> angles used in Radon transform
%       scale -> image scaling factor%
%
%   Output variable2:
%
%       meanRadon -> mean values of pixels in Radon-transform space
%       stdRadon -> standard deviations of pixels in Radon-transform space
%       vidObjs -> VideoReader objects for each of the aligned avi files
%
% (C) Gordon J. Berman, 2014
%     Princeton University


    files = findAllImagesInFolders(alignedImageDirectory,'avi');
    L = length(files);
    
    lengths = zeros(L,1);
    vidObjs = cell(L,1);
    parfor i=1:L
        vidObjs{i} = VideoReader(files{i});
        lengths(i) = vidObjs{i}.NumberOfFrames;
    end
    
    N = sum(lengths);
    cumsumLengths = [0;cumsum(lengths)];
    
    
    if nargin < 2 || isempty(numToTest)
        numToTest = N;
    end
    
    if numToTest > N
        idx = 1:N;
        numToTest = N;
    else
        idx = sort(randperm(N,numToTest));
    end

    
    groupings = cell(L,1);
    for i=1:L
        groupings{i} = idx(idx > cumsumLengths(i) & idx <= cumsumLengths(i+1));
    end
    
    testImage = read(vidObjs{1},1);
    testImage = testImage(:,:,1);
    
    s = size(testImage);
    nX = round(s(1)/scale);
    nY = round(s(2)/scale);
    s = [nX nY];
    testImage = radon(imresize(testImage,s),thetas);
    sR = size(testImage);
    
    
    radonImages = zeros(sR(1),sR(2),numToTest);
    fprintf(1,'Calculating Image Radon Transforms\n');
    count = 0;
    for i=1:L
        
        fprintf(1,'\t Computing Transforms for File #%7i out of %7i\n',i,L);
        
        M = length(groupings{i});
        currentImages = zeros(sR(1),sR(2),M);
        currentIdx = groupings{i} - cumsumLengths(i);
        q = vidObjs{i};
        
        parfor j=1:M
            
            image = read(q,currentIdx(j));
            image = image(:,:,1);
            a = double(imresize(image,s));
            lowVal = min(a(a>0));
            highVal = max(a(a>0));
            a = (a - lowVal) / (highVal - lowVal);
            
            currentImages(:,:,j) = radon(a,thetas);
            
        end
        
        radonImages(:,:,count + (1:M)) = currentImages;
        count = count + M;
        
        clear currentImages currentIdx M
        
    end
    
    
    
    fprintf(1,'Calculating Mean and Standard Deviation\n');
    meanRadon = zeros(sR);
    stdRadon = zeros(sR);
    for i=1:sR(1)
        for j=1:sR(2)
            meanRadon(i,j) = mean(squeeze(radonImages(i,j,:)));
            stdRadon(i,j) = std(squeeze(radonImages(i,j,:)));
        end
    end
    
    
    
    
    
    
    
    
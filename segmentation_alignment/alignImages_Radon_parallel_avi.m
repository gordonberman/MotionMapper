function [Xs,Ys,angles,areas,parameters,framesToCheck,svdskipped,areanorm] = ...
    alignImages_Radon_parallel_avi(file_path,startImage,finalImage,image_path,parameters)
%alignImages_Radon_parallel_avi runs the alignment and segmentation routines on a .avi file
%   and saves the output files to a directorty (called by ../runAlignment.m)
%
%   Input variables:
%
%       file_path -> avi file to be analyzed
%       startImage -> first frame of the avi file to be analyzed
%       finalImage -> last frame of the avi file to be analyzed
%       image_path -> path to which files are saved
%       parameters -> struct containing parameters
%
%
%   Output variables:
%
%       Xs -> alignment x translations
%       Ys -> alignment y translations
%       angles -> alignment rotations
%       areas -> segmented areas after segmentation
%       framesToCheck -> frames where a large rotation occurs in a single 
%                           frame.  This might signal a 180 degree rotation
%                           error
%       svdskipped -> blank frames where alignment is skipped
%       areanorm -> normalizing factor for fly size
%
% (C) Gordon J. Berman, 2014
%     Princeton University

    warning off MATLAB:polyfit:RepeatedPointsOrRescale;
    warning off MATLAB:audiovideo:aviinfo:FunctionToBeRemoved;
    
    readout = 100;
    nDigits = 8;
    
    spacing = parameters.alignment_angle_spacing;
    pixelTol = parameters.pixelTol;
    minArea = parameters.minArea;
    asymThreshold = parameters.asymThreshold;
    symLine = parameters.symLine;
    initialPhi = parameters.initialPhi;
    dilateSize = parameters.dilateSize;
    cannyParameter = parameters.cannyParameter;
    imageThreshold = parameters.imageThreshold;
    maxAreaDifference = parameters.maxAreaDifference;
    segmentationOff = parameters.segmentationOff;
    basisImage = parameters.basisImage;
    bodyThreshold = parameters.bodyThreshold;
    numProcessors = parameters.numProcessors;
    rangeExtension = parameters.rangeExtension;
    
    %Choose starting and finishing images
    
    vidObj = VideoReader(file_path);
    nFrames = vidObj.NumberOfFrames;
    
    if isempty(startImage)
        startImage = 1000;
    end
    
    if isempty(finalImage)
        if nFrames < 361000
            finalImage = nFrames;
        else
            finalImage = 361000;
        end
    end
    
        
    segmentationOptions.imageThreshold = imageThreshold;
    segmentationOptions.cannyParameter = cannyParameter;
    segmentationOptions.dilateSize = dilateSize;
    segmentationOptions.minArea = minArea;
    segmentationOptions.spacing = spacing;
    segmentationOptions.pixelTol = pixelTol;
    segmentationOptions.maxAreaDifference = maxAreaDifference;
    segmentationOptions.segmentationOff = segmentationOff;
    segmentationOptions.asymThreshold = asymThreshold;
    segmentationOptions.symLine = symLine;
    
    
    %Area normalization and (possibly) bodyThreshold finding
    
    idx = randi([startImage,nFrames],[parameters.areaNormalizationNumber,1]);
    basisSize = sum(basisImage(:)>0);
    s = size(basisImage);

    temp=vidObj.read(idx(1));
    if size(temp,3)>1
        IS_RGB = true;
        fprintf('WARNING: your movie is RGB. Using only R channel for processing.\n')
    else
        IS_RGB = false;
    end
    currentImageSet = uint8(zeros(s(1),s(2),parameters.areaNormalizationNumber));

    parfor ii=1:length(idx)
        temp = vidObj.read(idx(ii));
        if IS_RGB
            currentImageSet(:,:,ii) = temp(:,:,1);
        else
            currentImageSet(:,:,ii) = temp;
        end
    end
    
    if bodyThreshold < 0   
        T = zeros(length(idx),parameters.areaNormalizationNumber);
        parfor i=1:length(idx)
            [testImage,mask] = segmentImage_combo(currentImageSet(:,:,i),5,.05,[],[],[],1000,true);
            if sum(mask(:)) > 1000
                II = testImage(testImage>0);
                T(i) = autoFindThreshold_gmm(II,3);
            end
        end
        
        T = T(T>0);
        bodyThreshold = quantile(T,.25); 
        parameters.bodyThreshold = bodyThreshold;
         
    end
    
    
    if parameters.asymThreshold < 0
        parameters.asymThreshold = parameters.bodyThreshold;
        asymThreshold = parameters.asymThreshold;
    end
            
     
    imageSizes = zeros(size(idx));
    for j = 1:parameters.areaNormalizationNumber
        a = currentImageSet(:,:,j);
        imageSizes(j) = sum(imcomplement(a(:))>bodyThreshold);
    end
    imageSize = median(imageSizes);
    areanorm = sqrt(basisSize/imageSize);
    
        
    if isempty(image_path)
        image_path   = input('Image Path = ?:  ', 's');
    end
    
    [status,~]=unix(['ls ' image_path]);
    if status == 1
        unix(['mkdir ' image_path]);
    end
    
    if ~segmentationOff
        referenceImage = segmentImage_combo(basisImage,dilateSize,...
            cannyParameter,imageThreshold,[],[],minArea,true);
    else
        referenceImage = basisImage;
    end
    
    [ii,~] = find(referenceImage > 0);
    minRangeValue = min(ii) - rangeExtension;
    maxRangeValue = max(ii) + rangeExtension;
    
    segmentationOptions.referenceImage = referenceImage;
    segmentationOptions.minRangeValue = minRangeValue;
    segmentationOptions.maxRangeValue = maxRangeValue;
    
    %define groupings
    imageVals = startImage:finalImage;
    numImages = length(imageVals);
    minNumPer = floor(numImages / numProcessors+1e-20);
    remainder = mod(numImages,numProcessors);
    count = 1;
    groupings = cell(numProcessors,1);
    for i=1:numProcessors
        if i <= remainder
            groupings{i} = imageVals(count:(count+minNumPer));
            count = count + minNumPer + 1;
        else
            groupings{i} = imageVals(count:(count+minNumPer-1));
            count = count + minNumPer;
        end
    end

    
    
    % Write Out Grouping Start and Finish indices
    groupidx = zeros(length(groupings),2);
    for i = 1:length(groupings)
        groupidx(i,1) = groupings{i}(1);
        groupidx(i,2) = groupings{i}(end);
    end
    
    
    %initialize new avi files
    alignmentFiles = cell(numProcessors,1);
    fDigits = ceil(log10(numProcessors+1e-10));
    for i=1:numProcessors
        qq = num2str(i);
        qq = [repmat('0',1,fDigits - length(qq)) qq];
        alignmentFiles{i} = VideoWriter([image_path '/' qq '.avi']);
    end
    
    x1s = zeros(numProcessors,1);
    y1s = zeros(numProcessors,1);
    angle1s = zeros(numProcessors,1);
    area1s = zeros(numProcessors,1);
    svdskip1s = zeros(numProcessors,1);
    
    currentPhis = zeros(numProcessors,1);
    
    
    %initialize First Images
    
    images = cell(numProcessors,1);
    for j=1:numProcessors
        
        fprintf(1,'Finding initial orientation for processor #%2i\n',j);
        
        i = groupings{j}(1);
        
        originalImage = read(vidObj,i);
        if length(size(originalImage)) == 3
            originalImage = originalImage(:,:,1);
        end
        
        if ~segmentationOff
            imageOut = segmentImage_combo(originalImage,dilateSize,cannyParameter,...
                imageThreshold,[],[],minArea,true);
            imageOut = rescaleImage(imageOut,areanorm);
        else
            imageOut = originalImage;
            imageOut = rescaleImage(imageOut,areanorm);
        end
        
        imageOut2 = imageOut;
        imageOut2(imageOut2 < asymThreshold) = 0;
        
        if max(imageOut2(:)) ~= 0
            
            [angle1s(j),x1s(j),y1s(j),~,~,image] = ...
                alignTwoImages(referenceImage,imageOut2,initialPhi,spacing,pixelTol,false,imageOut);
            
            
            s = size(image);
            b = image;
            b(b > asymThreshold) = 0;
            if minRangeValue > 1
                b(1:minRangeValue-1,:) = 0;
            end
            if maxRangeValue < length(referenceImage(:,1))
                b(maxRangeValue+1:end,:) = 0;
            end
            
            
            q = sum(b) ./ sum(b(:));
            asymValue = symLine - sum(q.*(1:s(1)));
                        
            
            if asymValue < 0
                
                initialPhi = mod(initialPhi+180,360);
                
                [tempAngle,tempX,tempY,~,~,tempImage] = ...
                    alignTwoImages(referenceImage,imageOut2,initialPhi,spacing,pixelTol,false,imageOut);
                
                b = tempImage;
                b(b > asymThreshold) = 0;
                if minRangeValue > 1
                    b(1:minRangeValue-1,:) = 0;
                end
                if maxRangeValue < length(referenceImage(:,1))
                    b(maxRangeValue+1:end,:) = 0;
                end
                
                q = sum(b>0)./sum(b(:)>0);
                asymValue2 = symLine - sum(q.*(1:s(1)));
                
                if asymValue2 > asymValue
                    angle1s(j) = tempAngle;
                    x1s(j) = tempX;
                    y1s(j) = tempY;
                    image = tempImage;
                end
                
            end
            
            area1s(j) = sum(imageOut(:) ~= 0);
            currentPhis(j) = angle1s(j);
            images{j} = image;
            svdskip1s(j) = 0;
            
        else
            
            area1s(j) = sum(imageOut(:) ~= 0);
            currentPhis(j) = initialPhi;
            angle1s(j) = initialPhi;
            svdskip1s(j) = 1;
            image = uint8(zeros(size(imageOut2)));
            images{j} = image;
            
        end
        
    end
    
    
    fprintf(1,'Aligning Images\n');
    
    tic
    Xs_temp = cell(numProcessors,1);
    Ys_temp = cell(numProcessors,1);
    Angles_temp = cell(numProcessors,1);
    Areas_temp = cell(numProcessors,1);
    svdskips_temp = cell(numProcessors,1);
    
    
    parfor i=1:numProcessors
        
        [Xs_temp{i},Ys_temp{i},Angles_temp{i},Areas_temp{i},svdskips_temp{i}] = ...
            align_subroutine_parallel_avi(groupings{i},currentPhis(i),...
            segmentationOptions,nDigits,file_path,alignmentFiles{i},readout,i,...
            asymThreshold,area1s(i),vidObj,[],areanorm,images{i});
        
        
        
        Xs_temp{i}(1) = x1s(i);
        Ys_temp{i}(1) = y1s(i);
        Areas_temp{i}(1) = area1s(i);
        Angles_temp{i}(1) = angle1s(i);
        svdskips_temp{i}(1) = svdskip1s(i);
        
        close(alignmentFiles{i});   
        
    end
    
    
    Xs = combineCells(Xs_temp);
    Ys = combineCells(Ys_temp);
    angles = combineCells(Angles_temp);
    areas = combineCells(Areas_temp);
    svdskips = combineCells(svdskips_temp);
    
        
    
    x = abs(diff(unwrap(angles.*pi/180).*180/pi));
    framesToCheck = find(x > 90) + 1;
    svdskipped = find(svdskips == 1);
    

    
    


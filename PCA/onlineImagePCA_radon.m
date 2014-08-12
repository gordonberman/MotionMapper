function [mu,vecs,vals] = onlineImagePCA_radon(files,batchSize,scale,pixels,thetas,numPerFile)
%onlineImagePCA_radon finds postural eigenmodes based upon a set of
%aligned images (called by findPosturalEigenmodes.m).
%
%   Input variables:
%
%       files -> cell array of VideoReader objects
%       batchSize -> # of images to process at once
%       scale -> image scaling factor
%       pixels -> radon-transform space pixels to use (Lx1 or 1xL array)
%       thetas -> angles used in Radon transform
%       numPerFile -> # of images to use per file
%
%
%   Output variables:
%
%       mu -> mean value for each of the pixels
%       vecs -> postural eignmodes (LxL array).  Each column (vecs(:,i)) is 
%                   an eigenmode corresponding to the eigenvalue vals(i)
%       vals -> eigenvalues of the covariance matrix
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University

    
    if nargin < 3 || isempty(scale);
        scale = 10/7;
    end
    
    if nargin < 6 || isempty(numPerFile)
        numPerFile = -1;
    end
    
    
    Nf = length(files);
    lengths = zeros(Nf,1);
    for i=1:Nf
        lengths(i) = files{i}.NumberOfFrames;
    end
    
    
    L = length(pixels);
    
    
    testImage = read(files{1},1);
    testImage = testImage(:,:,1);
    s = size(testImage);
    nX = round(s(1)/scale);
    nY = round(s(2)/scale);
    s = [nX nY];
    
    firstBatch = true;
    tempMu = zeros(1,L);
    totalImages = 0;
    for t=1:Nf
        
        fprintf(1,'Processing File #%5i out of %5i\n',t,Nf);
        
        M = lengths(t);
        if numPerFile == -1
            currentNumPerFile = M;
        else
            currentNumPerFile = numPerFile;
        end
            
        
        if M < currentNumPerFile
            currentIdx = 1:M;
        else
            currentIdx = randperm(M,currentNumPerFile);
        end
        M = min([lengths(t) currentNumPerFile]);
        
        
        if M < batchSize
            currentBatchSize = M;
        else
            currentBatchSize = batchSize;
        end
        num = ceil(M/currentBatchSize);
        
        currentVideoReader = files{t};

        currentImage = 0;
        X = zeros(currentBatchSize,L);
        for j=1:num
            
            fprintf(1,'\t Batch #%5i out of %5i\n',j,num);
            
            if firstBatch
                
                firstBatch = false;
                
                parfor i=1:currentBatchSize
                    
                    a = read(currentVideoReader,currentIdx(i));
                    a = double(imresize(a(:,:,1),s));
                    lowVal = min(a(a>0));
                    highVal = max(a(a>0));
                    a = (a - lowVal) / (highVal - lowVal);
                    
                    R = radon(a,thetas);
                    X(i,:) = R(pixels);
                    
                end
                currentImage = currentBatchSize;
                
                mu = sum(X);
                C = cov(X).*currentBatchSize + (mu'*mu)./ currentBatchSize;
                
            else
                
                if j == num
                    maxJ = M - currentImage;
                else
                    maxJ = currentBatchSize;
                end
                
                tempMu(:) = 0;
                iterationIdx = currentIdx((1:maxJ) + currentImage);
                parfor i=1:maxJ
                    
                    a = read(currentVideoReader,iterationIdx(i));
                    a = double(imresize(a(:,:,1),s));
                    
                    lowVal = min(a(a>0));
                    highVal = max(a(a>0));
                    a = (a - lowVal) / (highVal - lowVal);
                    
                    R = radon(a,thetas);
                    y = R(pixels);
                    X(i,:) = y';
                    tempMu = tempMu + y';
                    
                end
                
                mu = mu + tempMu;
                C = C + cov(X(1:maxJ,:)).*maxJ + (tempMu'*tempMu)./maxJ;
                currentImage = currentImage + maxJ;
                
            end
                        
        end
                
        totalImages = totalImages + currentImage;
        
        
    end
    
    
       
    mu = mu ./ totalImages;
    C = C ./ totalImages - mu'*mu;
        
    fprintf(1,'Finding Principal Components\n');
    [vecs,vals] = eig(C);
    
    vals = flipud(diag(vals));
    vecs = fliplr(vecs);
    
   
    
    
    
    
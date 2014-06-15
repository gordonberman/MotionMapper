function [mu,vecs,vals,vecsS,valsS] = onlineImagePCA_radon(files,batchSize,scale,pixels,thetas)
%onlineImagePCA_radon finds postural eigenmodes based upon a set of
%aligned images (called by findPosturalEigenmodes.m).
%
%   Input variables:
%
%       files -> cell array of aligned .tiff files
%       batchSize -> # of files to process at once
%       scale -> image scaling factor
%       pixels -> radon-transform space pixels to use (Lx1 or 1xL array)
%       thetas -> angles used in Radon transform
%
%
%   Output variables:
%
%       mu -> mean value for each of the pixels
%       vecs -> postural eignmodes (LxL array).  Each column (vecs(:,i)) is 
%                   an eigenmode corresponding to the eigenvalue vals(i)
%       vals -> eigenvalues of the covariance matrix
%       vecsS -> postural eignmodes (LxL array) for the shuffled data.  
%                   Each column (vecs(:,i)) is an eigenmode corresponding 
%                   to the eigenvalue shuffledVals(i). (optional)
%       valsS -> eigenvalues of the shuffled covariance matrix (optional).
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University

    
    if nargin < 3
        scale = 10/7;
    end

    N = length(files);
    if N < batchSize
        batchSize = N;
    end
    files = files(randperm(N));
    num = ceil(N/batchSize);
    L = length(pixels);
    
    testImage = imread(files{1});
    s = size(testImage);
    nX = round(s(1)/scale);
    nY = round(s(2)/scale);
    s = [nX nY];
    
    
    fprintf(1,'Processing Initial Batch...\n');
    X = zeros(batchSize,L);
    parfor i=1:batchSize
        a = imresize(imread(files{i}),s);
        lowVal = min(a(a>0));
        highVal = max(a(a>0));
        a = (a - lowVal) / (highVal - lowVal);
        
        R = radon(a,thetas);
        X(i,:) = R(pixels);
    end
    currentImage = batchSize;
    
    mu = sum(X);
    C = cov(X).*batchSize + (mu'*mu)./ batchSize;
    if nargout > 3
        shuffledC = cov(shuffledMatrix(X)).*batchSize + (mu'*mu)./ batchSize;
    end
    
    tempMu = zeros(size(mu));
    for i=2:num
        fprintf(1,'Processing Batch #%5i of %5i, Image #%6i of %6i\n',i,num,currentImage,N);
        
        if i == num
            maxJ = N - currentImage;
        else
            maxJ = batchSize;
        end
    
        tempMu(:) = 0;
        parfor j=1:maxJ
            a = imresize(imread(files{currentImage+j}),s);
            lowVal = min(a(a>0));
            highVal = max(a(a>0));
            a = (a - lowVal) / (highVal - lowVal);
            
            R = radon(a,thetas);
            y = R(pixels);
            X(j,:) = y';
            tempMu = tempMu + y';         
        end
        
        mu = mu + tempMu;
        C = C + cov(X(1:maxJ,:)).*maxJ + (tempMu'*tempMu)./maxJ;
        if nargout > 3
            shuffledC = shuffledC + cov(shuffledMatrix(X(1:maxJ,:))).*maxJ + (tempMu'*tempMu)./maxJ;
        end
        currentImage = currentImage + maxJ;
                
    end
    
    mu = mu ./ N;
    C = C ./ N - mu'*mu;
    if nargout > 3
        shuffledC = shuffledC ./ N - mu'*mu;
    end
    
    fprintf(1,'Finding Principal Components\n');
    [vecs,vals] = eig(C);
    
    vals = flipud(diag(vals));
    vecs = fliplr(vecs);
    
    if nargout > 3
        fprintf(1,'Finding Shuffled Principal Components\n');
        [vecsS,valsS] = eig(shuffledC);
        
        valsS = flipud(diag(valsS));
        vecsS = fliplr(vecsS);
    end
    
    
    
    
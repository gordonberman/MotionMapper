function [vecs,vals,meanValue,shuffledVecs,shuffledVals] = findPosturalEigenmodes(filePath,pixels,parameters,firstFrame,lastFrame)
%findPosturalEigenmodes finds postural eigenmodes based upon a set of
%aligned images within a directory.
%
%   Input variables:
%
%       filePath -> directory containing aligned .tiff files
%       pixels -> radon-transform space pixels to use (Lx1 or 1xL array)
%       parameters -> struct containing non-default choices for parameters
%       firstFrame -> first image in path to be analyzed
%       lastFrame -> last image in path to be analyzed
%
%
%   Output variables:
%
%       vecs -> postural eignmodes (LxL array).  Each column (vecs(:,i)) is 
%                   an eigenmode corresponding to the eigenvalue vals(i)
%       vals -> eigenvalues of the covariance matrix
%       meanValue -> mean value for each of the pixels
%       shuffledVecs -> postural eignmodes (LxL array) for the shuffled 
%                           data.  Each column (vecs(:,i)) is an eigenmode 
%                           corresponding to the eigenvalue
%                           shuffledVals(i). (optional)
%       shuffledVals -> eigenvalues of the shuffled covariance matrix
%                           (optional).
%
% (C) Gordon J. Berman, 2014
%     Princeton University

    
    addpath(genpath('./utilities/'));
    addpath(genpath('./PCA/'));
    
    if nargin < 3
        parameters = [];
    end
    parameters = setRunParameters(parameters);
    
    
    if matlabpool('size') ~= parameters.numProcessors;
        matlabpool close force
        if parameters.numProcessors > 1
            matlabpool(parameters.numProcessors);
        end
    end
    
    
    files = findAllImagesInFolders(filePath,'tiff');
    N = length(files);
    
    if nargin < 4 || isempty(firstFrame)
        firstFrame = 1;
    end
    
    if nargin < 5 || isempty(lastFrame)
        lastFrame = N;
    end
    
    files = files(firstFrame:lastFrame);
    
    
    numThetas = parameters.num_Radon_Thetas;
    spacing = 180/numThetas;
    thetas = linspace(0,180-spacing,numThetas);
    scale = parameters.rescaleSize;
    batchSize = parameters.pca_batchSize;
    
    
    
    if nargout > 3
        [meanValue,vecs,vals,shuffledVecs,shuffledVals] = ...
            onlineImagePCA_radon(files,batchSize,scale,pixels,thetas);
    else
        [meanValue,vecs,vals] = ...
            onlineImagePCA_radon(files,batchSize,scale,pixels,thetas);
    end
    
    
    
    if parameters.numProcessors > 1 && parameters.closeMatPool
        matlabpool close
    end
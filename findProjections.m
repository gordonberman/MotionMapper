function projections = findProjections(filePath,vecs,meanValues,pixels,parameters,firstFrame,lastFrame)
%findPosturalEigenmodes finds the projection of a set of images onto
%postural eigenmodes.
%
%   Input variables:
%
%       filePath -> directory containing aligned .tiff files
%       vecs -> postural eignmodes (L x (M<L) array)
%       meanValues -> mean value for each of the pixels
%       pixels -> radon-transform space pixels to use (Lx1 or 1xL array)
%       parameters -> struct containing non-default choices for parameters
%       firstFrame -> first image in path to be analyzed
%       lastFrame -> last image in path to be analyzed
%
%
%   Output variables:
%
%       projections -> N x d array of projection values
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University

    
    addpath(genpath('./utilities/'));
    addpath(genpath('./PCA/'));
    
    if nargin < 5
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
    
    if nargin < 6 || isempty(firstFrame)
        firstFrame = 1;
    end
    
    if nargin < 7 || isempty(lastFrame)
        lastFrame = N;
    end
    
    files = files(firstFrame:lastFrame);
    
    
    numThetas = parameters.num_Radon_Thetas;
    spacing = 180/numThetas;
    thetas = linspace(0,180-spacing,numThetas);
    scale = parameters.rescaleSize;
    numProjections = parameters.numProjections;
    batchSize = parameters.pca_batchSize;
    
    projections = find_PCA_projections(files,vecs(:,1:numProjections),...
        meanValues,pixels,thetas,numProjections,scale,batchSize);
    
        
    if parameters.numProcessors > 1  && parameters.closeMatPool
        matlabpool close
    end
    
    
    
    
    
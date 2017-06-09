function projections = findProjections(filePath,vecs,meanValues,pixels,parameters)
%findPosturalEigenmodes finds the projection of a set of images onto
%postural eigenmodes.
%
%   Input variables:
%
%       filePath -> cell array of VideoReader objects or a directory 
%                       containing aligned .avi files
%       vecs -> postural eignmodes (L x (M<L) array)
%       meanValues -> mean value for each of the pixels
%       pixels -> radon-transform space pixels to use (Lx1 or 1xL array)
%       parameters -> struct containing non-default choices for parameters
%
%
%   Output variables:
%
%       projections -> N x d array of projection values
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University

    
    if nargin < 5
        parameters = [];
    end
    parameters = setRunParameters(parameters);
    
    
    setup_parpool(parameters.numProcessors)    
    
    %files = findAllImagesInFolders(filePath,'tiff');
    %N = length(files);
    
    if iscell(filePath)
        
        vidObjs = filePath;
        
    else
        
        files = findAllImagesInFolders(filePath,'avi');
        N = length(files);
        vidObjs = cell(N,1);
        parfor i=1:N
           vidObjs{i} = VideoReader(files{i}); 
        end
        
    end
    
    
    
    numThetas = parameters.num_Radon_Thetas;
    spacing = 180/numThetas;
    thetas = linspace(0,180-spacing,numThetas);
    scale = parameters.rescaleSize;
    numProjections = parameters.numProjections;
    batchSize = parameters.pca_batchSize;
    
    projections = find_PCA_projections(vidObjs,vecs(:,1:numProjections),...
        meanValues,pixels,thetas,numProjections,scale,batchSize);
    
        
    if parameters.numProcessors > 1  && parameters.closeMatPool
        close_parpool
    end
    
    
    
    
    
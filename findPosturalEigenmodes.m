function [vecs,vals,meanValue] = findPosturalEigenmodes(filePath,pixels,parameters)
%findPosturalEigenmodes finds postural eigenmodes based upon a set of
%aligned images within a directory.
%
%   Input variables:
%
%       filePath -> cell array of VideoReader objects or a directory 
%                       containing aligned .avi files
%       pixels -> radon-transform space pixels to use (Lx1 or 1xL array)
%       parameters -> struct containing non-default choices for parameters
%
%
%   Output variables:
%
%       vecs -> postural eignmodes (LxL array).  Each column (vecs(:,i)) is 
%                   an eigenmode corresponding to the eigenvalue vals(i)
%       vals -> eigenvalues of the covariance matrix
%       meanValue -> mean value for each of the pixels
%
% (C) Gordon J. Berman, 2014
%     Princeton University

    
    if nargin < 3
        parameters = [];
    end
    parameters = setRunParameters(parameters);
    
    
    setup_parpool(parameters.numProcessors)

    
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
    batchSize = parameters.pca_batchSize;
    numPerFile = parameters.pcaNumPerFile;
    
    [meanValue,vecs,vals] = ...
        onlineImagePCA_radon(vidObjs,batchSize,scale,pixels,thetas,numPerFile);
    
    
    
    if parameters.numProcessors > 1 && parameters.closeMatPool
        close_parpool
    end
function outputStruct = runAlignment(fileName,outputPath,startImage,finalImage,parameters)
%runAlignment runs the alignment and segmentation routines on a .avi file
%   and saves the output files to a directorty
%
%   Input variables:
%
%       fileName -> avi file to be analyzed
%       outputPath -> path to which files are saved
%       startImage -> first image in path to be analyzed
%       finalImage -> last image in path to be analyzed
%       parameters -> struct containing non-default choices for parameters
%
%
%   Output variable:
%
%       outputStruct -> struct containing found alignment variables
%
% (C) Gordon J. Berman, 2014
%     Princeton University


    if ~exist(outputPath,'dir')
        mkdir(outputPath);
    end
    
    
    if nargin < 3 || isempty(startImage)
        startImage = 1;
    end
    
    
    if nargin < 4 || isempty(finalImage)
        finalImage = [];
    end
    
    
    if nargin < 5 || isempty(parameters)
        parameters = [];
    end
    
    parameters = setRunParameters(parameters);
    
    
    setup_parpool(parameters.numProcessors)

    
    [Xs,Ys,angles,areas,~,framesToCheck,svdskipped,areanorm] = ...
        alignImages_Radon_parallel_avi(fileName,startImage,finalImage,...
                                        outputPath,parameters);
    
    
    %See alignImages_Radon_parallel_avi for definitions of these variables                                
    outputStruct.Xs = Xs;
    outputStruct.Ys = Ys;
    outputStruct.angles = angles;
    outputStruct.areas = areas;
    outputStruct.parameters = parameters;
    outputStruct.framesToCheck = framesToCheck;
    outputStruct.svdskipped = svdskipped;
    outputStruct.areanorm = areanorm;
    
    
    if parameters.numProcessors > 1 && parameters.closeMatPool
        close_parpool
    end
    
    
    
    
    
function [yData,signalData,signalIdx,signalAmps] = ...
                file_embeddingSubSampling(projectionFile,parameters)
%file_embeddingSubSampling finds the potential training set contributions 
%from a single file (called by runEmbeddingSubSampling.m)
%
%   Input variables:
%
%       projectionFile -> file to be analyzed (should contain a variable
%                           called 'projections')
%       parameters -> struct containing non-default choices for parameters
%
%
%   Output variables:
%
%       yData -> Nx2 array containing t-SNE embedding
%       signalData -> wavelet data corresponding to yData
%       signalIdx -> idx used
%       signalAmps -> wavelet amplitudes of signalData
%
% (C) Gordon J. Berman, 2014
%     Princeton University

    
    rtol = parameters.training_relTol;
    perplexity = parameters.training_perplexity;
    numPoints = parameters.training_numPoints;
    
    addpath(genpath('./wavelet/'));
    
    fprintf(1,'\t Loading Projections\n');
    load(projectionFile,'projections');
    
    
    N = length(projections(:,1));
    numModes = parameters.pcaModes;
    skipLength = floor(N / numPoints);
    if skipLength == 0
        skipLength = 1;
        numPoints = N;
    end
    firstFrame = mod(N,numPoints) + 1;
    signalIdx = firstFrame:skipLength:(firstFrame + (numPoints-1)*skipLength);
    
    fprintf(1,'\t Calculating Wavelets\n');
    [data,~] = findWavelets(projections,numModes,parameters);
    amps = sum(data,2);
    
    signalData = bsxfun(@rdivide,data(signalIdx,:),amps(signalIdx));
    signalAmps = amps(signalIdx);
    
    clear data amps;
    
    fprintf(1,'\t Calculating Distances\n');
    [D,~] = findKLDivergences(signalData);
    
    
    fprintf(1,'\t Running t-SNE\n');
    parameters.relTol = rtol;
    parameters.perplexity = perplexity;
    [yData,~,~,~] = tsne_d(D,parameters);
        
    
    
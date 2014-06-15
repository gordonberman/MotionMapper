function [amplitudes,f] = findWavelets(projections,numModes,parameters)
%findWavelets finds the wavelet transforms resulting from a time series
%
%   Input variables:
%
%       projections -> N x d array of projection values
%       numModes -> # of transforms to find
%       parameters -> struct containing non-default choices for parameters
%
%
%   Output variables:
%
%       amplitudes -> wavelet amplitudes (N x (pcaModes*numPeriods) )
%       f -> frequencies used in wavelet transforms (Hz)
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University

    
    addpath(genpath('./utilities/'));
    addpath(genpath('./wavelet/'));
    
    if nargin < 3
        parameters = [];
    end
    parameters = setRunParameters(parameters);
    
    
    L = length(projections(1,:));
    if nargin < 2 || isempty(numModes)
        numModes = L;
    else
        if numModes > L
            numModes = L;
        end
    end
    
    
    if matlabpool('size') ~= parameters.numProcessors;
        matlabpool close force
        if parameters.numProcessors > 1
            matlabpool(parameters.numProcessors);
        end
    end
    
    
    omega0 = parameters.omega0;
    numPeriods = parameters.numPeriods;
    dt = 1 ./ parameters.samplingFreq;
    minT = 1 ./ parameters.maxF;
    maxT = 1 ./ parameters.minF;
    Ts = minT.*2.^((0:numPeriods-1).*log(maxT/minT)/(log(2)*(numPeriods-1)));
    f = fliplr(1./Ts);
    
    
    N = length(projections(:,1));
    amplitudes = zeros(N,numModes*numPeriods);
    for i=1:numModes
        amplitudes(:,(1:numPeriods)+(i-1)*numPeriods) = ...
            fastWavelet_morlet_convolution_parallel(...
            projections(:,i),f,omega0,dt)';
    end
    
    
    if parameters.numProcessors > 1 && parameters.closeMatPool
        matlabpool close
    end
    
    
    
    
    
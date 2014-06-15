function [xx,density] = findPointDensity(points,sigma,numPoints,rangeVals)
%findPointDensity finds a Kernel-estimated PDF from a set of 2D data points
%through convolving with a gaussian function
%
%   Input variables:
%
%       points -> N x 2 array of data points
%       sigma -> standard deviation of smoothing gaussian
%       numPoints -> number of points in each dimension of 'density'
%       rangeVals -> 1 x 2 array giving the extrema of the observed range
%
%
%   Output variables:
%
%       xx -> 1 x numPoints array giving the x and y axis evaluation points
%       density -> numPoints x numPoints array giving the PDF values 
%
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University



    if nargin < 3 || isempty(numPoints)
        numPoints = 1001;
    else
        if mod(numPoints,2) == 0
            numPoints = numPoints + 1;
        end
    end
    
    if nargin < 4 || isempty(rangeVals)
        rangeVals = [-110 110];
    end

    xx = linspace(rangeVals(1),rangeVals(2),numPoints);
    yy = xx;
    [XX,YY] = meshgrid(xx,yy);
    
    G = exp(-.5.*(XX.^2 + YY.^2)./sigma^2) ./ (2*pi*sigma^2);
    
    Z = hist3(points,{xx,yy});
    Z = Z ./ (sum(Z(:)));
    
    density = fftshift(real(ifft2(fft2(G).*fft2(Z))))';
    density(density<0) = 0;

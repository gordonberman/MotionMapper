function [rotationAngle,X,Y,finalImage,errors,finalOriginalImage] = ...
            alignTwoImages(image1,image2,angleGuess,spacing,...
                    fractionalPixelAccuracy,noRotation,originalImage)
%alignTwoImages rotationally and translationally aligns an image with a 
%background image
%
%   Input variables:
%
%       image1 -> background image
%       image2 -> image to be aligned
%       angleGuess -> initial guess to eliminate 180 degree degeneracy
%       spacing -> angular spacing in Radon transform
%       fractionalPixelAccuracy -> accuracy of translational alignment
%       noRotation -> true if only translational alignment used
%       originalImage -> full version of image2 (optional)
%
%
%   Output variables:
%
%       rotationAngle -> rotational alignment angle
%       X, Y -> translational alignment values (in pixels)
%       finalImage -> aligned version of image2
%       errors -> errors in alignment
%       finalOriginalImage -> aligned version of originalImage (optional)
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University
        
        

    if nargin < 3 || isempty(angleGuess) == 1
        angleGuess = 0;
    else
        angleGuess = mod(angleGuess,360);
    end
    
    angleGuess = angleGuess*pi/180;
    
    
    if nargin < 4 || isempty(spacing) == 1
        spacing = .5;
    end
    N = 180/spacing;
    
    
    if nargin < 5 || isempty(fractionalPixelAccuracy) == 1
        fractionalPixelAccuracy = .25;
    end
    
    
    if nargin < 6 || isempty(noRotation)
        noRotation = false;
    end
    
    
    if nargin < 7
        originalImage = [];
        finalOriginalImage = [];
    end
    
    errors = zeros(2,1);
    
    s = size(image1);
    
    if ~noRotation
        
        thetas = linspace(0, 180-spacing, N);
        
        %Find fft of the Radon transform       
        F1 = abs(fft(radon(image1, thetas)));
        F2 = abs(fft(radon(image2, thetas)));
        
        
        
        %Find the index of the correlation peak
        correlation = sum(fft2(F1) .* fft2(F2));
        peaks = real(ifft(correlation));
        peakIndex = find(peaks==max(peaks));
        
        
        if length(peakIndex) > 1
            peakIndex = peakIndex(1);
        end
        
        
        %Find rotation angle via quadratic interpolation
        if (peakIndex~=1) && (peakIndex ~= N)
            p=polyfit(thetas((peakIndex-1):(peakIndex+1)),peaks((peakIndex-1):(peakIndex+1)),2);
            rotationAngle = -.5*p(2)/p(1);
            errors(1) = polyval(p,rotationAngle);
        else
            if peakIndex == 1
                p = polyfit([thetas(end)-180,thetas(1),thetas(2)],peaks([N,1,2]),2);
                rotationAngle = -.5*p(2)/p(1);
                errors(1) = polyval(p,rotationAngle);
                if rotationAngle < 0
                    rotationAngle = 180 + rotationAngle;
                end
            else
                p = polyfit([thetas(end-1),thetas(end),180+thetas(1)],peaks([N-1,N,1]),2);
                rotationAngle = -.5*p(2)/p(1);
                errors(1) = polyval(p,rotationAngle);
                if rotationAngle >= 180
                    rotationAngle = rotationAngle - 180;
                end
            end
        end
        
              
        %Check to see if rotation angle is in the correct direction
        rA = rotationAngle*pi/180;
        test = dot([cos(rA),sin(rA)],[cos(angleGuess),sin(angleGuess)]);
        if test < 0
            rotationAngle = mod(rotationAngle-180,360);
        end
        rotationAngle = mod(rotationAngle,360);
        toRotate = mod(-rotationAngle,360);
        
        %Rotate Image & Crop to original Size
        rotatedImage = imrotate(image2,toRotate,'crop');
        
    else
        
        rotationAngle = mod(angleGuess,360);
        toRotate = mod(-rotationAngle,360);
        rotatedImage = imrotate(image2,toRotate,'crop');
        
    end
    
    % Take 2D FFT of each image
    F1 = fft2(image1);
    F2 = fft2(rotatedImage);
    
    shifts = dftregistration(F1,F2,round(1/fractionalPixelAccuracy));
    X = shifts(4);
    Y = shifts(3);
    
    errors(2) = shifts(1);
    
    
    T = maketform('affine',[1 0 0 ;0 1 0;X Y 1]);
    if nargout > 3
        finalImage = imtransform(rotatedImage,T,'XData',[1 s(2)],'YData',[1 s(1)]);
    end
    
    if isempty(originalImage) == 0
        rotatedImage2 = imrotate(originalImage,toRotate,'crop');
        finalOriginalImage = imtransform(rotatedImage2,T,'XData',[1 s(2)],'YData',[1 s(1)]);
    end


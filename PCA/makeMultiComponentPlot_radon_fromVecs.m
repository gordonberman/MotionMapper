function image = makeMultiComponentPlot_radon_fromVecs(C,N,thetas,pixels,imageSize)
%makes an pictoral representation of a set of postural eigenmodes
%
% Inputs:
%   C -> Lxd matrix of eigenvectors (each along a column) to be plotted
%   N -> number of eigenvectors to be chosen (first N will be used)
%   thetas -> angles in radon transform
%   pixels -> Radon-transformed space pixels that are used
%   imageSize -> size of Radon-transformed image

    if nargin < 2 || isempty(N)
        N = length(C(1,:));
    end
    
    if nargin < 5 || isempty(imageSize)
        imageSize = [201 90];
    end

    L = ceil(sqrt(N));
    M = ceil(N/L);
    
    r1 = imageSize(1);
    r2 = imageSize(2);
    
    test = iradon(zeros(r1,r2),thetas);
    s = size(test);
    P = s(1);
    Q = s(2);
    
    currentImage = zeros(r1,r2);
    for i=1:N
        currentImage(pixels) = C(:,i);
        X1 = mod(i-1,M)+1;
        Y1 = ceil(i/M);
        image(((Y1-1)*P+1):(Y1*P),((X1-1)*Q+1):(X1*Q)) = iradon(currentImage,thetas);
    end
    
    imagesc(image);
    axis equal 
    axis off
    caxis([-3e-3 3e-3])
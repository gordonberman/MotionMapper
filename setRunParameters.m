function parameters = setRunParameters(parameters)
%setRunParameters sets all parameters for the algorithms used here.
%       Any parameters not explicitly set will revert to their listed
%       default values.
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University


    if nargin < 1
        parameters = [];
    end

    
    
    %%%%%%%% General Parameters %%%%%%%%
    
    %number of processors to use in parallel code
    numProcessors = 12;
    
    %whether or not to close the matlabpool after running a routine
    closeMatPool = false;
    
    
    
    
    
    %%%%%%%% Segmentation and Alignment Parameters %%%%%%%%
    
    %angle spacing for alignement Radon transform
    alignment_angle_spacing = 1;
    
    %tolerance for translational alignment
    pixelTol = .1;
    
    %minimum area for use in image dilation/erosion
    minArea = 3500;
    
    %asymmetry threshold used in eliminating rotational degeneracy (set to -1 for auto)
    asymThreshold = 150;
    
    %line about which directional symmetry is 
    %determined for eliminating rotational degeneracy
    symLine = 110;
    
    %initial guess for rotation angle
    initialPhi = 0;

    %initial dilation size for image segmentation
    dilateSize = 5;

    %parameter for Canny edge detection
    cannyParameter = .1;

   %threshold for image segmentation
    imageThreshold = 40;

    %largest allowed percentage reduction in area from frame to frame
    maxAreaDifference = .15;

    %toggle switch for image segmentation (alignment still performed)
    segmentationOff = false;
    
    %threshold for seperating body from background (set to -1 for auto)
    bodyThreshold = 150;

    %number of images to test for image size estimation
    areaNormalizationNumber = 100;
    
    %range extension for flipping detector
    rangeExtension = 20;
    
    %path to basis image
    basisImagePath = 'segmentation_alignment/basisImage.tiff';
    
    
    
    
    
    %%%%%%%% PCA Parameters %%%%%%%% 
    
    %number of angles in radon transform
    num_Radon_Thetas = 90;
    
    %image scaling factor
    rescaleSize = 10/7;
    
    %batch size for running online PCA
    pca_batchSize = 20000;
    
    %number of projections to find in PCA
    numProjections = 100;
    
    %number of PCA modes to use in later analyses
    pcaModes = 50;
    
    %number of images to process per file in eignemode calculations
    %a value of -1 instructs all images to be processed
    pcaNumPerFile = -1;
    
    
    %%%%%%%% Wavelet Parameters %%%%%%%%
    
    %number of wavelet frequencies to use
    numPeriods = 25;
    
    %dimensionless Morlet wavelet parameter
    omega0 = 5;
    
    %sampling frequency (Hz)
    samplingFreq = 100;
        
    %minimum frequency for wavelet transform (Hz)
    minF = 1;
    
    %maximum frequency for wavelet transform (Hz)
    maxF = 50;
    
    
    
    
    
    
    %%%%%%%% t-SNE Parameters %%%%%%%%
    
    
    %2^H (H is the transition entropy)
    perplexity = 32;
    
    %relative convergence criterium for t-SNE
    relTol = 1e-4;
    
    %number of dimensions for use in t-SNE
    num_tsne_dim = 2;
    
    %binary search tolerance for finding pointwise transition region
    sigmaTolerance = 1e-5;
    
    %maximum number of non-zero neighbors in P
    maxNeighbors = 200;
    
    %initial momentum
    momentum = .5;
    
    %value to which momentum is changed
    final_momentum = 0.8;    
    
    %iteration at which momentum is changed
    mom_switch_iter = 250;      
    
    %iteration at which lying about P-values is stopped
    stop_lying_iter = 125;      
    
    %degree of P-value expansion at early iterations
    lie_multiplier = 4;
    
    %maximum number of iterations
    max_iter = 1000;  
    
    %initial learning rate
    epsilon = 500;  
    
    %minimum gain for delta-bar-delta
    min_gain = .01;   

    %readout variable for t-SNE
    tsne_readout = 1;
    
    %embedding batchsize
    embedding_batchSize = 20000;
    
    %maximum number of iterations for the Nelder-Mead algorithm
    maxOptimIter = 100;
    
    %number of points in the training set
    trainingSetSize = 35000;
    
    %local neighborhood definition in training set creation
    kdNeighbors = 5;
    
    %t-SNE training set stopping critereon
    training_relTol = 2e-3;
    
    %t-SNE training set perplexity
    training_perplexity = 20;
    
    %number of points to evaluate in each training set file
    training_numPoints = 10000;
    
    %minimum training set template length
    minTemplateLength = 1;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if ~isfield(parameters,'numProcessors') || isempty(parameters.numProcessors)
        parameters.numProcessors = numProcessors;
    end
    
    
    if ~isfield(parameters,'closeMatPool') || isempty(parameters.closeMatPool)
        parameters.closeMatPool = closeMatPool;
    end
    
    
    


    
    if ~isfield(parameters,'alignment_angle_spacing') || isempty(parameters.alignment_angle_spacing)
        parameters.alignment_angle_spacing = alignment_angle_spacing;
    end
    
    
    if ~isfield(parameters,'bodyThreshold') || isempty(parameters.bodyThreshold)
        parameters.bodyThreshold = bodyThreshold;
    end
    
    
    if ~isfield(parameters,'pixelTol') || isempty(parameters.pixelTol)
        parameters.pixelTol = pixelTol;
    end
    
    
    if ~isfield(parameters,'minArea') || isempty(parameters.minArea)
        parameters.minArea = minArea;
    end
    
    
    if ~isfield(parameters,'asymThreshold') || isempty(parameters.asymThreshold)
        parameters.asymThreshold = asymThreshold;
    end
    
    
    if ~isfield(parameters,'symLine') || isempty(parameters.symLine)
        parameters.symLine = symLine;
    end
    
    
    if ~isfield(parameters,'basisImagePath') || isempty(parameters.basisImagePath) 
        parameters.basisImagePath = basisImagePath;
    end
    parameters.basisImage = imread(parameters.basisImagePath);
    

    if ~isfield(parameters,'initialPhi') || isempty(parameters.initialPhi)
        parameters.initialPhi = initialPhi;
    end


    if ~isfield(parameters,'dilateSize') || isempty(parameters.dilateSize)
        parameters.dilateSize = dilateSize;
    end
    

    if ~isfield(parameters,'cannyParameter') || isempty(parameters.cannyParameter)
        parameters.cannyParameter = cannyParameter;
    end


    if ~isfield(parameters,'imageThreshold') || isempty(parameters.imageThreshold)
        parameters.imageThreshold = imageThreshold;
    end

    
    if ~isfield(parameters,'maxAreaDifference') || isempty(parameters.maxAreaDifference)
        parameters.maxAreaDifference = maxAreaDifference;
    end


    if ~isfield(parameters,'segmentationOff') || isempty(parameters.segmentationOff)
        parameters.segmentationOff = segmentationOff;
    end



    

    
    

    if ~isfield(parameters,'num_Radon_Thetas') || isempty(parameters.num_Radon_Thetas)
        parameters.num_Radon_Thetas = num_Radon_Thetas;
    end
    
    
    if ~isfield(parameters,'rescaleSize') || isempty(parameters.rescaleSize)
        parameters.rescaleSize = rescaleSize;
    end


    if ~isfield(parameters,'pca_batchSize') || isempty(parameters.pca_batchSize)
        parameters.pca_batchSize = pca_batchSize;
    end


    if ~isfield(parameters,'numProjections') || isempty(parameters.numProjections)
        parameters.numProjections = numProjections;
    end
    
    
    if ~isfield(parameters,'pcaModes') || isempty(parameters.pcaModes)
        parameters.pcaModes = pcaModes;
    end
    
    
    
    
    
    
    
    
    
    
    if ~isfield(parameters,'numPeriods') || isempty(parameters.numPeriods)
        parameters.numPeriods = numPeriods;
    end
    
    
    if ~isfield(parameters,'omega0') || isempty(parameters.omega0)
        parameters.omega0 = omega0;
    end
    
    
    if ~isfield(parameters,'samplingFreq') || isempty(parameters.samplingFreq)
        parameters.samplingFreq = samplingFreq;
    end
    
    
    if ~isfield(parameters,'minF') || isempty(parameters.minF)
        parameters.minF = minF;
    end
    
    
    if ~isfield(parameters,'maxF') || isempty(parameters.maxF)
        parameters.maxF = maxF;
    end
    
    
    
    
    
    
    
    
    
    if ~isfield(parameters,'perplexity') || isempty(parameters.perplexity)
        parameters.perplexity = perplexity;
    end
    
    
    if ~isfield(parameters,'relTol') || isempty(parameters.relTol)
        parameters.relTol = relTol;
    end
    
    
    if ~isfield(parameters,'num_tsne_dim') || isempty(parameters.num_tsne_dim)
        parameters.num_tsne_dim = num_tsne_dim;
    end
    
    
    if ~isfield(parameters,'sigmaTolerance') || isempty(parameters.sigmaTolerance)
        parameters.sigmaTolerance = sigmaTolerance;
    end
    
    
    if ~isfield(parameters,'maxNeighbors') || isempty(parameters.maxNeighbors)
        parameters.maxNeighbors = maxNeighbors;
    end
    
    
    if ~isfield(parameters,'momentum') || isempty(parameters.momentum)
        parameters.momentum = momentum;
    end
    
    
    if ~isfield(parameters,'final_momentum') || isempty(parameters.final_momentum)
        parameters.final_momentum = final_momentum;
    end
    
    
    if ~isfield(parameters,'mom_switch_iter') || isempty(parameters.mom_switch_iter)
        parameters.mom_switch_iter = mom_switch_iter;
    end
    
    
    if ~isfield(parameters,'stop_lying_iter') || isempty(parameters.stop_lying_iter)
        parameters.stop_lying_iter = stop_lying_iter;
    end
    
    
    if ~isfield(parameters,'lie_multiplier') || isempty(parameters.lie_multiplier)
        parameters.lie_multiplier = lie_multiplier;
    end
    
    
    if ~isfield(parameters,'max_iter') || isempty(parameters.max_iter)
        parameters.max_iter = max_iter;
    end
    
    
    if ~isfield(parameters,'epsilon') || isempty(parameters.epsilon)
        parameters.epsilon = epsilon;
    end
    
    
    if ~isfield(parameters,'min_gain') || isempty(parameters.min_gain)
        parameters.min_gain = min_gain;
    end
    
    
    if ~isfield(parameters,'tsne_readout') || isempty(parameters.tsne_readout)
        parameters.tsne_readout = tsne_readout;
    end
    
    
    if ~isfield(parameters,'embedding_batchSize') || isempty(parameters.embedding_batchSize)
        parameters.embedding_batchSize = embedding_batchSize;
    end
    
    
    if ~isfield(parameters,'maxOptimIter') || isempty(parameters.maxOptimIter)
        parameters.maxOptimIter = maxOptimIter;
    end
    
    
    if ~isfield(parameters,'trainingSetSize') || isempty(parameters.trainingSetSize)
        parameters.trainingSetSize = trainingSetSize;
    end
    
    
    if ~isfield(parameters,'kdNeighbors') || isempty(parameters.kdNeighbors)
        parameters.kdNeighbors = kdNeighbors;
    end
    
    
    if ~isfield(parameters,'training_relTol') || isempty(parameters.training_relTol)
        parameters.training_relTol = training_relTol;
    end
    
    
    if ~isfield(parameters,'training_perplexity') || isempty(parameters.training_perplexity)
        parameters.training_perplexity = training_perplexity;
    end
    
    
    if ~isfield(parameters,'training_numPoints') || isempty(parameters.training_numPoints)
        parameters.training_numPoints = training_numPoints;
    end
    
    
    if ~isfield(parameters,'minTemplateLength') || isempty(parameters.minTemplateLength)
        parameters.minTemplateLength = minTemplateLength;
    end
    
    
    if ~isfield(parameters,'pcaNumPerFile') || isempty(parameters.pcaNumPerFile)
        parameters.pcaNumPerFile = pcaNumPerFile;
    end
    
    
    if ~isfield(parameters,'areaNormalizationNumber') || isempty(parameters.areaNormalizationNumber)
        parameters.areaNormalizationNumber = areaNormalizationNumber;
    end
    
    
    if ~isfield(parameters,'rangeExtension') || isempty(parameters.rangeExtension)
        parameters.rangeExtension = rangeExtension;
    end
    
    
    
    
   
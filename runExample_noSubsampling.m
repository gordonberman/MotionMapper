%%example script that will run the code for a single .avi file (moviePath)
%%This version does not perform subsampling to find a training set

%Place path to folder containing example .avi files here
moviePath = '';

%add utilities folder to path
addpath(genpath('./utilities/'));
addpath(genpath('./PCA/'));
addpath(genpath('./segmentation_alignment/'));
addpath(genpath('./t_sne/'));
addpath(genpath('./wavelet/'));

%set file path
[filePath,fileName,~] = fileparts(moviePath);
filePath = [filePath '/' fileName '/'];
imageFiles = {moviePath};
L = length(imageFiles);
numZeros = ceil(log10(L+1e-10));

[status,~]=unix(['ls ' filePath]);
if status ~= 0
    unix(['mkdir ' filePath]);
end

%define any desired parameter changes here
parameters.samplingFreq = 100;
parameters.trainingSetSize = 5000;

%initialize parameters
parameters = setRunParameters(parameters);

firstFrame = 1;
lastFrame = [];

%% Run Alignment

%creating alignment directory
alignmentDirectory = [filePath '/alignment_files/'];
if ~exist(alignmentDirectory,'dir')
    mkdir(alignmentDirectory);
end
    

%run alignment for all files in the directory
fprintf(1,'Aligning Files\n');
alignmentFolders = cell(L,1);
ii=1;

fileNum = [repmat('0',1,numZeros-length(num2str(ii))) num2str(ii)];
tempDirectory = [alignmentDirectory 'alignment_' fileNum '/'];
alignmentFolders{ii} = tempDirectory;
outputStruct = runAlignment(imageFiles{ii},tempDirectory,firstFrame,lastFrame,parameters);

save([tempDirectory 'outputStruct.mat'],'outputStruct');

    



%% Find image subset statistics (a gui will pop-up here)

fprintf(1,'Finding Subset Statistics\n');
numToTest = parameters.pca_batchSize;
[pixels,thetas,means,stDevs,vidObjs] = findRadonPixels(alignmentDirectory,numToTest,parameters);


%% Find postural eigenmodes

fprintf(1,'Finding Postural Eigenmodes\n');
[vecs,vals,meanValues] = findPosturalEigenmodes(vidObjs,pixels,parameters);

vecs = vecs(:,1:parameters.numProjections);

figure
makeMultiComponentPlot_radon_fromVecs(vecs(:,1:25),25,thetas,pixels,[201 90]);
caxis([-3e-3 3e-3])
colorbar
title('First 25 Postural Eigenmodes','fontsize',14,'fontweight','bold');
drawnow;


%% Find projections

projectionsDirectory = [filePath './projections/'];
if ~exist(projectionsDirectory,'dir')
    mkdir(projectionsDirectory);
end

fprintf(1,'Finding Projections\n');
ii=1;
projections = findProjections(alignmentFolders{ii},vecs,meanValues,pixels,parameters);

fileNum = [repmat('0',1,numZeros-length(num2str(ii))) num2str(ii)];
fileName = imageFiles{ii};

save([projectionsDirectory 'projections_' fileNum '.mat'],'projections','fileName');

    
%% Embed training set

fprintf(1,'Calculating Wavelet Transform\n');
[data,f] = findWavelets(projections,parameters.pcaModes,parameters);   

amps = sum(data,2);
data(:) = bsxfun(@rdivide,data,amps);

skipLength = round(length(data(:,1))/parameters.trainingSetSize);

trainingSetData = data(skipLength:skipLength:end,:);
trainingAmps = amps(skipLength:skipLength:end);
parameters.signalLabels = log10(trainingAmps);


fprintf(1,'Finding t-SNE Embedding for Training Set\n');
[trainingEmbedding,betas,P,errors] = run_tSne(trainingSetData,parameters);


%% Find All Embeddings

fprintf(1,'Finding t-SNE Embedding for all Data\n');
embeddingValues = cell(L,1);
i=1;

[embeddingValues{ii},~] = findEmbeddings(data,trainingSetData,trainingEmbedding,parameters);



%% Make density plots


maxVal = max(max(abs(combineCells(embeddingValues))));
maxVal = round(maxVal * 1.1);

sigma = maxVal / 40;
numPoints = 501;
rangeVals = [-maxVal maxVal];

[xx,density] = findPointDensity(combineCells(embeddingValues),sigma,numPoints,rangeVals);

densities = zeros(numPoints,numPoints,L);
for i=1:L
    [~,densities(:,:,ii)] = findPointDensity(embeddingValues{ii},sigma,numPoints,rangeVals);
end


figure
maxDensity = max(density(:));
imagesc(xx,xx,density)
axis equal tight off xy
caxis([0 maxDensity * .8])
colormap(jet)
colorbar



figure

N = ceil(sqrt(L));
M = ceil(L/N);
maxDensity = max(densities(:));
for i=1:L
    subplot(M,N,ii)
    imagesc(xx,xx,densities(:,:,ii))
    axis equal tight off xy
    caxis([0 maxDensity * .8])
    colormap(jet)
    title(['Data Set #' num2str(ii)],'fontsize',12,'fontweight','bold');
end



close_parpool


%%example script that will run the code for a set of images found in ??

%Place path to example files here
filePath = '';

%add utilities folder to path
addpath(genpath('./utilities/'));

%find all avi files in 'filePath'
imageFiles = findAllImagesInFolders(filePath,'.avi');
L = length(imageFiles);
numZeros = ceil(log10(L+1e-10));

%define any desired parameter changes here
parameters.samplingFreq = 100;
parameters.trainingSetSize = 5000;

%initialize parameters
parameters = setRunParameters(parameters);

firstFrame = 1;
lastFrame = [];

%% 

%creating alignment directory
alignmentDirectory = [filePath '/alignment_files/'];
if ~exist(alignmentDirectory,'dir')
    mkdir(alignmentDirectory);
end
    

%run alignment for all files in the directory
fprintf(1,'Aligning Files\n');
alignmentFolders = cell(L,1);
for i=1:L    
    
    fprintf(1,'\t Aligning File #%4i out of %4i\n',i,L);
    
    fileNum = [repmat('0',1,numZeros-length(num2str(i))) num2str(i)];
    tempDirectory = [alignmentDirectory 'alignment_' fileNum '/'];
    alignmentFolders{i} = tempDirectory;
    
    outputStruct = runAlignment(imageFiles{i},tempDirectory,firstFrame,lastFrame,parameters);
    
    save([tempDirectory 'outputStruct.mat'],'outputStruct');
    
    clear outputStruct
    clear fileNum
    clear tempDirectory
    
end


%% 


%find image subset statistics (a gui will pop-up here)
fprintf(1,'Finding Subset Statistics\n');
numToTest = parameters.pca_batchSize;
[pixels,thetas,means,stDevs,vidObjs] = findRadonPixels(alignmentDirectory,numToTest,parameters);


%% 

%find postural eigenmodes (not performing shuffled analysis for now)
fprintf(1,'Finding Postural Eigenmodes\n');
[vecs,vals,meanValues] = findPosturalEigenmodes(vidObjs,pixels,parameters);

vecs = vecs(:,1:parameters.numProjections);

figure
makeMultiComponentPlot_radon_fromVecs(vecs(:,1:25),25,thetas,pixels,[201 90]);
caxis([-3e-3 3e-3])
colorbar
title('First 25 Postural Eigenmodes','fontsize',14,'fontweight','bold');
drawnow;


%% 

%find projections for each data set
projectionsDirectory = [filePath './projections/'];
if ~exist(projectionsDirectory,'dir')
    mkdir(projectionsDirectory);
end

fprintf(1,'Finding Projections\n');
for i=1:L
    
    fprintf(1,'\t Finding Projections for File #%4i out of %4i\n',i,L);
    projections = findProjections(alignmentFolders{i},vecs,meanValues,pixels,parameters);
    
    fileNum = [repmat('0',1,numZeros-length(num2str(i))) num2str(i)];
    fileName = imageFiles{i};
    
    save([projectionsDirectory 'projections_' fileNum '.mat'],'projections','fileName');
    
    clear projections
    clear fileNum
    clear fileName 
    
end


%% 

%Uses subsampled t-SNE to find training set 
fprintf(1,'Finding Training Set\n');
[trainingSetData,trainingSetAmps,projectionFiles] = ...
    runEmbeddingSubSampling(projectionsDirectory,parameters);

%% 


%Runs t-SNE on training set
fprintf(1,'Finding t-SNE Embedding for the Training Set\n');
[trainingEmbedding,betas,P,errors] = run_tSne(trainingSetData,parameters);


%% 

%Find Embeddings for each file
fprintf(1,'Finding t-SNE Embedding for each file\n');
embeddingValues = cell(L,1);
for i=1:L
    
    fprintf(1,'\t Finding Embbeddings for File #%4i out of %4i\n',i,L);
    
    load(projectionFiles{i},'projections');
    projections = projections(:,1:parameters.pcaModes);
    
    [embeddingValues{i},~] = ...
        findEmbeddings(projections,trainingSetData,trainingEmbedding,parameters);

    clear projections
    
end

%% 

%Making density plots

addpath(genpath('./t_sne/'));
addpath(genpath('./utilities/'));

maxVal = max(max(abs(combineCells(embeddingValues))));
maxVal = round(maxVal * 1.1);

sigma = maxVal / 40;
numPoints = 501;
rangeVals = [-maxVal maxVal];

[xx,density] = findPointDensity(combineCells(embeddingValues),sigma,numPoints,rangeVals);

densities = zeros(numPoints,numPoints,L);
for i=1:L
    [~,densities(:,:,i)] = findPointDensity(embeddingValues{i},sigma,numPoints,rangeVals);
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
    subplot(M,N,i)
    imagesc(xx,xx,densities(:,:,i))
    axis equal tight off xy
    caxis([0 maxDensity * .8])
    colormap(jet)
    title(['Data Set #' num2str(i)],'fontsize',12,'fontweight','bold');
end




matlabpool close












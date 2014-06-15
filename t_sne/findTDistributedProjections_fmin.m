function [zValues,zCosts,zGuesses,inConvHull,meanMax,exitFlags] = ...
    findTDistributedProjections_fmin(data,trainingData,...
                                        trainingEmbedding,parameters)                                    
%findTDistributedProjections_fmin is called by runEmbbedings to find the
%optimal embeddings of a set of wavelet amplitudes into a previously
%defined t-SNE embedding

    
    readout = 5000;
    
    perplexity = parameters.perplexity;
    sigmaTolerance = parameters.sigmaTolerance;
    maxNeighbors = parameters.maxNeighbors;
    batchSize = parameters.embedding_batchSize;
    maxOptimIter = parameters.maxOptimIter;
    
        
    N = length(data(:,1));
    zValues = zeros(N,2);
    zGuesses = zeros(N,2);
    zCosts = zeros(N,1);
    batches = ceil(N/batchSize);
    inConvHull = false(N,1);
    meanMax = zeros(N,1);
    exitFlags = zeros(N,1);

    options = optimset('Display','off','maxiter',maxOptimIter);
    
    for j=1:batches
        fprintf(1,'\t Processing batch #%4i out of %4i\n',j,batches);
        idx = (1:batchSize) + (j-1)*batchSize;
        idx = idx(idx <= N);
        current_guesses = zeros(length(idx),2);
        current = zeros(length(idx),2);
        currentData = data(idx,:);
        tCosts = zeros(size(idx));
        current_poly = false(length(idx),1);
        
        D2 = findListKLDivergences(currentData,trainingData);
        current_meanMax = zeros(length(idx),1);
        
        parfor i=1:length(idx)
            
            if mod(i,readout) == 0
                fprintf(1,'\t\t Image #%5i\n',i);
            end
            
            [~,p] = returnCorrectSigma_sparse(D2(i,:),perplexity,sigmaTolerance,maxNeighbors);
            idx2 = p>0;
            z = trainingEmbedding(idx2,:);
            [~,maxIdx] = max(p);
            a = sum(bsxfun(@times,z,p(idx2)'));
                        
            guesses = [a;trainingEmbedding(maxIdx,:)];
            
            b = zeros(2,2);
            c = zeros(2,1)
            flags = zeros(2,1);
            
            q = convhull(z);
            q = z(q,:);
            
            [b(1,:),c(1),flags(1)] = fminsearch(@(x)calculateKLCost(x,z,p(idx2)),guesses(1,:),options);
            [b(2,:),c(2),flags(2)] = fminsearch(@(x)calculateKLCost(x,z,p(idx2)),guesses(2,:),options);
            polyIn = inpolygon(b(:,1),b(:,2),q(:,1),q(:,2));
            
            if sum(polyIn) > 0
                pp = find(polyIn);
                [~,mI] = min(c(polyIn));
                mI = pp(mI);
                current_poly(i) = true;
            else
                [~,mI] = min(c);
                current_poly(i) = false;
            end
            
            exitFlags(i) = flags(mI);
            current_guesses(i,:) = guesses(mI,:);
            current(i,:) = b(mI,:);
            tCosts(i) = c(mI);
            current_meanMax(i) = mI;
            
        end
        
        
        zGuesses(idx,:) = current_guesses;
        zValues(idx,:) = current;
        zCosts(idx) = tCosts;
        inConvHull(idx) = current_poly;
        meanMax(idx) = current_meanMax;
        
    end
    
    
    zValues(~inConvHull,:) = zGuesses(~inConvHull,:);
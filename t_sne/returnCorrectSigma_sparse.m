function [sigma,p] = returnCorrectSigma_sparse(ds,perplexity,tol,maxNeighbors)
%returnCorrectSigma_sparse is used by findTDistributedProjections_fmin.m to
%find the correct transition probabilities given a set of distances

    if nargin < 2 || isempty(perplexity)
        perplexity = 32;
    end


    if nargin < 3 || isempty(tol)
        tol = 1e-5;
    end

    s = size(ds);    
    
    highGuess = max(ds);
    lowGuess = 1e-10;

    sigma = .5*(highGuess + lowGuess);
    [~,sortIdx] = sort(ds);
    ds = ds(sortIdx(1:maxNeighbors));
    p = exp(-.5*ds.^2./sigma^2);
    p = p./sum(p);
    idx = p>0;
    H = sum(-p(idx).*log(p(idx))./log(2));
    P = 2^H;
    
    if abs(P-perplexity) < tol
        test = false;
    else
        test = true;
    end
    
    while test
        
        if P > perplexity
            highGuess = sigma;
        else
            lowGuess = sigma;
        end
        
        sigma = .5*(highGuess + lowGuess);
        
        p = exp(-.5*ds.^2./sigma^2);
        p = p./sum(p);
        idx = p>0;
        H = sum(-p(idx).*log(p(idx))./log(2));
        P = 2^H;
        
        if abs(P-perplexity) < tol
            test = false;
        end
        
    end
    
    
    if nargout == 2
        if s(1) == 1
            p = sparse(1,sortIdx(1:maxNeighbors),p,s(1),s(2));
        else
            p = sparse(sortIdx(1:maxNeighbors),1,p,s(1),s(2));
        end
    end
    
    
    
    
    
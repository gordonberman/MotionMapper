function [threshold,obj] = autoFindThreshold_gmm(data,k,replicates)

    if nargin < 3 || isempty(replicates)
        replicates = 10;
    end
    

    if ~isa(class(data),'double')
        data = double(data);
    end

    obj = gmixPlot(data,k,[],[],true,[],[],[],replicates);
    [~,sortIdx] = sort(obj.mu,'descend');
    
    minVal = min(data(:));
    maxVal = max(data(:));
    xx = linspace(minVal,maxVal,10000)';
    posts = posterior(obj,xx);
    
    f = fit(xx,posts(:,sortIdx(1))-posts(:,sortIdx(2)),'linearinterp');
    threshold = fzero(f,.5*(obj.mu(sortIdx(1)) + obj.mu(sortIdx(2))));
    
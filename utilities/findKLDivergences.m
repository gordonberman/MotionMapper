function [D,entropies] = findKLDivergences(data)
%finds the KL-divergences (D) and entropies between all rows in 'data'

    N = length(data(:,1));
    logData = log(data);
    logData(isinf(logData) | isnan(logData)) = 0;
    
    entropies = -sum(data.*logData,2);
    
    D = - data * logData';
    D = bsxfun(@minus,D,entropies);
    
    D = D ./ log(2);
    D(1:(N+1):end) = 0;
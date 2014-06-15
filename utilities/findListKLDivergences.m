function [D,entropies] = findListKLDivergences(data,data2)
%finds the KL-divergences (D) and entropies between all rows in 'data' and
%all rows in 'data2'

    logData = log(data);

    entropies = -sum(data.*logData,2);
    clear logData;  

    logData2 = log(data2);  

    D = - data * logData2';
    
    D = bsxfun(@minus,D,entropies); 
        
    D = D ./ log(2);
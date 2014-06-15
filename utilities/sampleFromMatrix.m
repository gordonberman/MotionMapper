function out = sampleFromMatrix(data,N)

    L = length(data(:,1));
    if L <= N
        out = data;
    else
        q = randperm(L);
        out = data(q(1:N),:);
    end
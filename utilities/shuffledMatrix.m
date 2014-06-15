function out = shuffledMatrix(x)

    N = length(x(:,1));
    L = length(x(1,:));
    
    out = zeros(N,L);
    for i=1:L
        q = randperm(N);
        out(:,i) = x(q,i);
    end
function lengths = returnCellLengths(x)

    L = length(x(:));
    lengths = zeros(size(x));
    
    for i=1:L
        lengths(i) = length(x{i}(:));
    end
    
function out = combineCells(x,dim,d)
%combines a collection of cells either horizontally or vertically,
%depending on the initial orientation


    x = x(returnCellLengths(x) > 0);

    if isempty(x)
        
        out = [];
        
    else
             
        L = length(x);
        lengths = returnCellLengths(x);
        [~,maxIdx] = max(lengths);
        s = size(x{maxIdx});
        
        if nargin < 2 || isempty(dim)
            dim = argmax(s);
        end
        
        if dim == 1
            
            if nargin  < 3 || isempty(d)
                d = s(2);
            end
            lengths = returnCellLengths(x) ./ d;
            s2 = size(lengths);
            if s2(2) > s2(1)
                lengths = lengths';
            end
            cVals = [0; cumsum(lengths)];
            
            out = zeros(cVals(end),d);
            
            for i=1:L
                if ~isempty(x{i})
                    out(cVals(i)+1:cVals(i+1),:) = x{i};
                end
            end
            
        else
            
            if nargin  < 3 || isempty(d)
                d = s(1);
            end
            lengths = returnCellLengths(x) ./ d;
            s2 = size(lengths);
            if s2(1) > s2(2)
                lengths = lengths';
            end
            cVals = [0 cumsum(lengths)];
            
            
            out = zeros(d,cVals(end));
            
            for i=1:L;
                if ~isempty(x{i})
                    out(:,cVals(i)+1:cVals(i+1)) = x{i};
                end
            end
            
        end
        
    end
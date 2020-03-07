function out = calculateKLCost(x,ydata,ps)
%calculateKLCost is used by findTDistributedProjections_fmin.m to calculate
%an optimal embedding point
    d = sum((ydata-x).^2,2)';
    out = log(sum((1+d).^-1)) + sum(ps.*log(1+d));

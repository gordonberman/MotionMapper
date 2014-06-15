function [obj,residuals,Z] = gmixPlot(X,N,MaxIter,bins,plotOFF,plotSubGaussians,obj,xlimits,replicates)
%finds and plots (optional) a gaussian mixture model fit to a 1d data set
%
%Inputs:
%X = column vector of data
%N = number of clusters
%MaxIter = max iterations of GMM fit
%bins = number of bins to display
%plotsOFF = turns plotting off and on
%plotSubGaussians = turn subgaussian plots on and off
%obj = inputted GMM
%xlimits = x limits for plot
%replicates = # of replicates for GMM

%Outputs:
%obj = GMM object
%residuals = GMM errors
%Z = histogram bins (Z = {Xvalues, Yvalues})



    if nargin < 3 || isempty(MaxIter) 
        MaxIter = 10000;
    end
    
    if nargin < 4 || isempty(bins)
        bins = 50;
    end
    
    if nargin < 5 || isempty(plotOFF) 
        plotOFF = false;
    end
    
    if nargin < 6 || isempty(plotSubGaussians)
        plotSubGaussians = false;
    end

    if nargin < 9 || isempty(replicates)
        replicates = 1;
    end
    
    if nargin < 7 || isempty(obj)
        options = statset('MaxIter',MaxIter,'Robust','on');
        obj = gmdistribution.fit(X,N,'Options',options,'Replicates',replicates,'Regularize',1e-30);
    else
        N = length(obj.mu);
    end
    
    
    
    
    if nargout > 1 || ~plotOFF
        [YY,XX] = hist(X,bins);
        YY = YY ./ (sum(YY)*(XX(2) - XX(1)));
        g = @(x) pdf(obj,x);
        residuals = YY' - g(XX');
        Z = {XX,YY};
    end
    
    
    if ~plotOFF
        
        %figure
        bar(XX,YY)
        if nargin < 8 || isempty(xlimits)
            xlimits = [XX(1) XX(end)];
        end
        xx = linspace(xlimits(1),xlimits(2),1000);
        hold on
        
        if plotSubGaussians && N > 1
            g = @(x,mu,sigma,p) p*exp(-.5*(x-mu).^2./sigma^2)./sqrt(2*pi*sigma^2);
            for i=1:N
                plot(xx,g(xx,obj.mu(i),sqrt(obj.Sigma(i)),obj.PComponents(i)),'g-','linewidth',2)
            end
        end
        
        
        h = plot(xx,pdf(obj,xx'));
        set(h,'linewidth',2)
        set(h,'Color','r')
        
        
        
        
        xlimits = [xlimits 0 max(YY)*1.1];
        axis(xlimits);
        
        
        
    end

    
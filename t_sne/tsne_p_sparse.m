function [ydata,errors] = tsne_p_sparse(P, parameters, no_dims, relTol)
%TSNE_P Performs symmetric t-SNE on affinity matrix P
%
%  [ydata,errors] = tsne_p(P, labels, no_dims, relTol)
%
% The function performs symmetric t-SNE on pairwise similarity matrix P 
% to create a low-dimensional map of no_dims dimensions (default = 2).
% The matrix P is assumed to be symmetric, sum up to 1, and have zeros
% on the diagonal.
% The labels of the data are not used by t-SNE itself, however, they 
% are used to color intermediate plots. Please provide an empty labels
% matrix [] if you don't want to plot results during the optimization.
% The low-dimensional data representation is returned in mappedX.
%
%
%   Input variables:
%
%       P -> NxN sparse transition probability matrix
%       parameters -> structure containing non-default parameters
%       no_dims -> number of dimensions for use in t-SNE (or an initial
%                           condition if a multi-member array)
%       relTol -> relative convergence criterium
%
%
%   Output variables:
%
%       ydata -> Nx2 (or Nx3) array of embedded values
%       errors -> D_{KL}(P || Q) as a function of iteration
%
%
% (C) Laurens van der Maaten, 2010
% University of California, San Diego
%
%  Modified by Gordon J. Berman, 2014
%  Princeton University

    readout = parameters.tsne_readout;
    
    
    if ~exist('no_dims', 'var') || isempty(no_dims)
        no_dims = 2;
    end
    
    if ~exist('relTol', 'var') || isempty(relTol)
        relTol = 1e-4;
    end
    
    % First check whether there is an initial solution
    if numel(no_dims) > 1
        initial_solution = true;
        ydata = no_dims;
        no_dims = size(ydata, 2);
    else
        initial_solution = false;
    end

    
    % Initialize some variables
    n = size(P, 1);   
    
    momentum = parameters.momentum;
    final_momentum = parameters.final_momentum;
    mom_switch_iter = parameters.mom_switch_iter;
    stop_lying_iter = parameters.stop_lying_iter;
    max_iter = parameters.max_iter;
    epsilon = parameters.epsilon;
    min_gain = parameters.min_gain;
    lie_multiplier = parameters.lie_multiplier;
    old_cost = 1e10;
    
    
    % Make sure p-vals are set properly
    P(1:(n + 1):end) = 0;                       
    P = 0.5 * (P + P');                         
    idx = P > 0;
    P(idx) = P(idx) ./ sum(P(:));                 
    idx = P > 0;
    
     % constant in KL divergence
    const = sum(P(idx) .* log2(P(idx)));
    
    
     % lie about the p-vals to find better local minima
    if ~initial_solution
        P = P * lie_multiplier;                                     
        lying_stopped = false;
    else
        lying_stopped = true;
    end
    
    
    % Initialize the solution
    if ~initial_solution
        ydata = .0001 * randn(n, no_dims);
    end

    y_incs  = zeros(size(ydata));
    gains = ones(size(ydata));

    
    % Run the iterations
    errors = zeros(max_iter,1);
    for iter=1:max_iter
        
        %find distances
        Q = 1 ./ (1 + squareform(pdist(ydata)).^2);
        Q(1:n+1:end) = 0;
        Z = sum(Q(:));
        Q = Q./Z;
        
        
        % Compute the gradients 
        L = Z * (P - Q) .* Q;
        y_grads = 4 * (diag(sum(L, 1)) - L) * ydata;

        
        
        % Update the solution (note that the y_grads are actually -y_grads)
        gains = (gains + .2) .* (sign(y_grads) ~= sign(y_incs)) ...        
              + (gains * .8) .* (sign(y_grads) == sign(y_incs));
        gains(gains < min_gain) = min_gain;
        y_incs = momentum * y_incs - epsilon * (gains .* y_grads);
        ydata = ydata + y_incs;
        ydata = bsxfun(@minus, ydata, mean(ydata, 1));

        
        %find error value
        cost = const - sum(P(idx) .* log2(Q(idx)));
        diffVal = (old_cost - cost) / old_cost;
        old_cost = cost;
        errors(iter) = cost;
       
        % Update the momentum if necessary
        if iter == mom_switch_iter
            momentum = final_momentum;
            lying_stopped = true;
        end
        if iter == stop_lying_iter && ~initial_solution
            P = P ./ lie_multiplier;     
        end
        
        % Print out progress
        if ~rem(iter, readout)
            
            disp(['Iteration ' num2str(iter) ': error is ' num2str(cost) ,', change is ' num2str(diffVal)]);
            
            if isfield(parameters,'signalLabels')
                if length(ydata(1,:)) == 2
                    scatter(ydata(:,1),ydata(:,2),[],parameters.signalLabels,'filled')
                    axis equal 
                else
                    scatter3(ydata(:,1),ydata(:,2),ydata(:,3),[],parameters.signalLabels,'filled')
                    axis equal 
                end
                drawnow;
            end
            
            
        end
        
        
        if abs(diffVal) < relTol && lying_stopped && iter > 10
            break;
        end
        
    end
    
    
    errors = errors(1:iter);
    

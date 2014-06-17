function [yData,betas,P,errors] = tsne_d(D, parameters)
%TSNE_D Performs symmetric t-SNE on the pairwise Euclidean distance matrix D
%
%   [yData,betas,P,errors] = tsne_d(D, parameters)
%
% The function performs symmetric t-SNE on the NxN pairwise  
% distance matrix D to construct an embedding with no_dims dimensions 
% (default = 2). An initial solution obtained from an other dimensionality 
% reduction technique may be specified in initial_solution. 
% The perplexity of the Gaussian kernel that is employed can be specified 
% through perplexity. 
%
%
%   Input variables:
%
%       D -> NxN distance matrix 
%       parameters -> structure containing non-default parameters
%
%
%   Output variables:
%
%       yData -> Nx2 (or Nx3) array of embedded values
%       betas -> list of individual area parameters
%       P -> sparse transition matrix
%       errors -> D_{KL}(P || Q) as a function of iteration
%
%
% (C) Laurens van der Maaten, 2010
% University of California, San Diego
%
%  Modified by Gordon J. Berman, 2014
%  Princeton University


    no_dims = parameters.num_tsne_dim;
    perplexity = parameters.perplexity;
    sigmaTolerance = parameters.sigmaTolerance;
    relTol = parameters.relTol;
    

    if numel(no_dims) > 1
        initial_solution = true;
        yData = no_dims;
        no_dims = size(ydata, 2);
    else
        initial_solution = false;
    end
    
    
    D = D / max(D(:));                                                      
    [P,betas] = d2p_sparse(D .^ 2, perplexity, sigmaTolerance);                                     
    
    clear D
    
    % Run t-SNE
    if initial_solution
        [yData,errors] = tsne_p_sparse(P, parameters, yData, relTol);
    else
        [yData,errors] = tsne_p_sparse(P, parameters, no_dims, relTol);
    end
    
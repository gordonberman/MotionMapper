function close_parpool
    % close the parallel pool in the correct for different versions 
    % of MATLAB.
    %
    % function close_parpool
    %
    % Rob Campbell - TENSS 2017


    % Is the parallel computing toolbox installed?
    if isempty(ver('distcomp'))
        fprintf('No parallel computing toolbox installed\n')
        return
    end


    % Start the desired number of workers. Delete existing pool with wrong number
    % of workers if needed.
    if verLessThan('matlab','8.3')
        matlabpool close
    else
        delete(gcp('nocreate'))
    end
        
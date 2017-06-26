function setup_parpool(desiredPoolSize)
    % Set up a parallel pool of the desired number of workers
    %
    %  function setup_parpool(desiredPoolSize)
    %
    % Runs the correct parallel pool setup function for different versions 
    % of MATLAB.
    %
    % Inputs
    % desiredPoolSize - an integer specifying the desired number of workers
    %
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

        if matlabpool('size') ~= desiredPoolSize;
            matlabpool close force
            if desiredPoolSize > 1
                matlabpool(desiredPoolSize);
            end
        end

    else

        g=gcp;
        if g.NumWorkers ~= desiredPoolSize
            delete(gcp('nocreate'))
            if desiredPoolSize > 1
                parpool(desiredPoolSize);
            end
        end

    end
        
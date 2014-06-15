function [signalData,signalAmps] = findTemplatesFromData(...
                    signalData,yData,signalAmps,numPerDataSet,parameters)
%findTemplatesFromData finds the training set contributions 
%from a single file (called by runEmbeddingSubSampling.m) 


    kdNeighbors = parameters.kdNeighbors;
    minTemplateLength = parameters.minTemplateLength;
    
    plotsOn = false;
    
    
    fprintf(1,'\t Finding Templates\n');
    [templates,~,~,~,templateLengths,~,vals] = ...
        returnTemplates(yData,signalData,minTemplateLength,...
                        kdNeighbors,plotsOn);
        
    
    N = length(templates);
    d = length(signalData(1,:));
    selectedData = zeros(numPerDataSet,d);
    selectedAmps = zeros(numPerDataSet,1);
    
    numInGroup = round(numPerDataSet*templateLengths/sum(templateLengths));
    numInGroup(numInGroup == 0) = 1;
    sumVal = sum(numInGroup);
    if sumVal < numPerDataSet
        q = numPerDataSet - sumVal;
        idx = randperm(N,q);
        numInGroup(idx) = numInGroup(idx) + 1;
    else
        if sumVal > numPerDataSet
            q = sumVal - numPerDataSet;
            idx2 = find(numInGroup > 1);
            Lq = length(idx2);
            if Lq < q
                idx2 = 1:length(numInGroup);
            end
            idx = randperm(length(idx2),q);
            numInGroup(idx2(idx)) = numInGroup(idx2(idx)) - 1;
        end
    end
    cumSumGroupVals = [0; cumsum(numInGroup)];
    
    
    for j=1:N;
        
        amps = signalAmps(vals == j);
        
        idx2 = randperm(length(templates{j}(:,1)),numInGroup(j));
        selectedData(cumSumGroupVals(j)+1:cumSumGroupVals(j+1),:) = templates{j}(idx2,:);
        selectedAmps(cumSumGroupVals(j)+1:cumSumGroupVals(j+1)) = amps(idx2);
        
    end
    
    signalData = selectedData;
    signalAmps = selectedAmps;
    
    

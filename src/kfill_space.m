function [ filledVals ] = kfill_space(fillVals,toFillCoords,initMul) 

if nargin < 3
   initMul = 3 ; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numVals = length(fillVals) ;
numCoords = size(toFillCoords,1) ;

filledVals = ones(numCoords,1) ;

% if theres only one value to fill
if numVals == 1  
    filledVals = filledVals .* fillVals(1) ;
    return
end 

% here, we are going for real sparse with the number of points 
numSubsmp = numVals * initMul ;
randInd = randperm(numCoords,numSubsmp) ;
% do an initial kmeans on X% data to get centroids.
randStartCoords = toFillCoords(randInd,:) ;

% get centroids for this 1% kmeans
[~,randStartCents] = kmeans(randStartCoords,numVals,...
                            'Start','sample') ;

% now knn these centroids, for all coordinates
kVals = knnsearch(randStartCents,toFillCoords) ;

% fill the output var
for idx = 1:numVals
    filledVals(kVals == idx) = fillVals(idx) ;   
end






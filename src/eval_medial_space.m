function [ labelsToReSeed ] = eval_medial_space(origMask,rotVals,spaceVal,distStr)

if nargin < 3
    spaceVal = 1 ;
end

if nargin < 4
    distStr = 'chebychev' ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% rotated mask
% and reduce rotated mask, if its not fully rotated outside orig mask
rotMask = (rotVals == spaceVal) .* ~origMask ;
% and get size of space
sizeSpace = sum(rotMask) ;

% need to figure out whats in the old black hole
parcInSpc = rotVals(logical(origMask)) ;

% get the labels that appear in the space of where the 'black hole' was
% orignally... we want to move these labels that rotated into this space to
% the location of the new 'black hole' space
labsInSpc = unique(parcInSpc) ;

% if the space didnt rotate completely off of the original space, we should
% act accordingly by removing the space val from our list
labsInSpc = labsInSpc(labsInSpc ~= spaceVal) ; 

% number 
numLabsInSpc = size(labsInSpc,1) ;

% uniq vals, that are not the space val
uniqueParcs = unique(rotVals) ;
uniqueParcs = uniqueParcs(uniqueParcs ~= spaceVal) ;

% distribution of community sizes
parcSzDist = arrayfun(@(t)nnz(rotVals==t), uniqueParcs) ;

% get a parc with only the areas touching black
prcntAreaInBlack = zeros(numLabsInSpc,1) ;

for idx = 1:length(labsInSpc)
   
    currLab = labsInSpc(idx) ;    

    prcntAreaInBlack(idx) = sum(origMask(rotMask == currLab)) / ...
                                sum(rotMask == currLab) ;    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now, go through reSeed list, sorted by largest percent in black 

[~,sortIdx] = sort(prcntAreaInBlack) ;
reSeedLabs = labsInSpc(sortIdx) ;

newSzDist = cell(numLabsInSpc,1) ;

% init a new pacc
newParc = rotVals .* 1 ;
newParc(logical(origMask)) = spaceVal ;

for idx = 1:length(reSeedLabs)

    % get current lab
    currLab = reSeedLabs(idx) ;
    
    % new parc
    newParc(newParc == currLab) = spaceVal ;
    
    % get the new hist of sizes
    tmp = arrayfun(@(t)nnz(newParc==t), uniqueParcs) ;
    % and in the zero places, put 'expected value'
    tmp(tmp == 0) = sizeSpace / idx ;
    
    newSzDist{idx} = tmp ;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% return the labs you should change

maxDiffs = cellfun(@(t)pdist([ t' ; parcSzDist'],distStr),newSzDist) ;
minMax = min(maxDiffs) ;
minMaxInd = find(maxDiffs == minMax,1,'last') ;

% reSeed labs are all the labs up until this index
labelsToReSeed = reSeedLabs(1:minMaxInd) ;





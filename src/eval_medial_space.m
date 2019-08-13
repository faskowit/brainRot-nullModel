function [ labelsToReSeed ] = eval_medial_space(origBlkSpcMask,rotVals,blackSpaceVal,distStr)

if nargin < 3
    blackSpaceVal = 1 ;
end

if nargin < 4
    distStr = 'chebychev' ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% rotated mask and reduce rotated mask, if its not fully rotated outside 
% original mask (inverted) (this could make new rotated mask smaller in
% theory if it did not rotate off original black gole
newBlkSpc = (rotVals == blackSpaceVal) .* ~origBlkSpcMask ;
% and get size of space
szNewBlkSpc = sum(newBlkSpc) ;

% need to figure out whats in the old black hole
parcInOrigBlkSpc = rotVals(logical(origBlkSpcMask)) ;

% get the labels that appear in the space of where the 'black hole' was
% orignally... we want to move these labels that rotated into this space to
% the location of the new 'black hole' space
labsInOrigBlkSpc = unique(parcInOrigBlkSpc) ;

% if the space didnt rotate completely off of the original space, we should
% act accordingly by removing the space val from our list
labsInOrigBlkSpc = labsInOrigBlkSpc(labsInOrigBlkSpc ~= blackSpaceVal) ; 

% number 
numLabsInOrigBlkSpc = size(labsInOrigBlkSpc,1) ;

% uniq vals, that are not the black space
uniqueOrigVals = unique(rotVals) ;
uniqueOrigVals = uniqueOrigVals(uniqueOrigVals ~= blackSpaceVal) ;

% get a parc with only the areas touching black
prcntAreaInOrigBlk = zeros(numLabsInOrigBlkSpc,1) ;
for idx = 1:length(labsInOrigBlkSpc)
    
    currLab = labsInOrigBlkSpc(idx) ;    
    prcntAreaInOrigBlk(idx) = sum(origBlkSpcMask(rotVals == currLab)) / ...
                                sum(rotVals == currLab) ;    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now, go through reSeed list, sorted by largest percent in black 

% start with labels having highest percentage in black
[~,sortIdx] = sort(prcntAreaInOrigBlk,'descend') ;
reSeedLabs = labsInOrigBlkSpc(sortIdx) ;

newSzDist = cell(numLabsInOrigBlkSpc,1) ;

% init a new pacc
newParc = rotVals .* 1 ;
newParc(logical(origBlkSpcMask)) = blackSpaceVal ;

% iterate through each label, recording a new hypothetical size
% distribution based on dividing the black space into equal parts
for idx = 1:length(reSeedLabs)

    % get current lab
    currLab = reSeedLabs(idx) ;
    
    % new parc
    newParc(newParc == currLab) = blackSpaceVal ;
    
    % get the new hist of sizes
    tmp = arrayfun(@(t)nnz(newParc==t), uniqueOrigVals) ;
    % and in the zero places, put 'expected value' by divding the size of
    % the new black space by the iteration here
    tmp(tmp == 0) = szNewBlkSpc / idx ;
    
    newSzDist{idx} = tmp ;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% return the labs you should change

% distribution of community sizes
origParcSzDist = arrayfun(@(t)nnz(rotVals==t), uniqueOrigVals) ;

szdistDist = cellfun(@(t)pdist([ t' ; origParcSzDist'],distStr),newSzDist) ;
minDist = min(szdistDist) ;
% find the min, but the last instance of it, to err on side of filling
% black hole with more values
lastMinInd = find(szdistDist == minDist,1,'last') ;

% reSeed labs are all the labs up until this index
labelsToReSeed = reSeedLabs(1:lastMinInd) ;





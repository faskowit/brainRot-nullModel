function newParc = get_null_parc_wFilled(origParc,rotParc,medialWallVal,fillVals,surfCoords)

% obtain masks
origMedialWallMask = (origParc == medialWallVal) ;
rotMedialWallMask = (rotParc == medialWallVal) ;

% get only new blackHole outside of old black hole
%  by multipling by old backHole converse
rotMedialWallMask = rotMedialWallMask .* ~origMedialWallMask ;

% get the new coordinates you want
newMedialWallCoors = surfCoords(logical(rotMedialWallMask),:) ;

% function [ filledVals ] = kfill_space(fillVals,toFillCoords,initPrcnt) 
filledValsInMedialWall = kfill_space(fillVals,newMedialWallCoors) ;

% initialize newParc var
newParc = rotParc .* 1 ;

% all fill vals we 'pop' because they'll be moved to new place
newParc(logical(sum(bsxfun(@eq,newParc,fillVals'),2))) = medialWallVal ;

% now put the new labs into the parc
newParc(logical(rotMedialWallMask)) = filledValsInMedialWall ;
newParc(origMedialWallMask) = medialWallVal ;
%% clear stuff
clc
clearvars

%% setup path

addpath(genpath(pwd))

%% load some data

% example just for left hemi
lh_sphere = [ pwd '/data/external/fsaverage/surf/lh.sphere' ] ;
% rh_sphere = [ pwd '/data/external/fsaverage/surf/rh.sphere' ] ;
lh_inflated = [ pwd '/data/external/fsaverage/surf/lh.inflated' ] ;
% rh_inflated = [ pwd '/data/external/fsaverage/surf/rh.inflated' ] ;
lh_annot = [ pwd '/data/external/fsaverage/label/lh.aparc.a2009s.annot' ] ;
% rh_annot = [ pwd '/data/external/fsaverage/label/rh.aparc.a2009s.annot' ] ;

%% read in data

[~,lh_annotLabs,annotTable] = read_annotation(lh_annot) ;
[lh_sphere_verts,lh_sphere_faces] = read_surf(lh_sphere);

% make index start at 1
lh_sphere_faces = lh_sphere_faces + 1;

% label at each vertex
labels = ones(length(lh_annotLabs),1);
for idx = 1:size(annotTable.table,1)
    labels(lh_annotLabs == annotTable.table(idx,5)) = idx;
end

cmap = annotTable.table(:,1:3) ./ 255 ;

%% get the 'black hole', created by subcortical and callosal structures

% this is the value it will be in 'labels' var
blackHoleVal = 1 ;

% get the 'black hole' area
blackHoleMask = (labels == blackHoleVal) ; 

%% viz before

figure
quick_plot_surf(lh_sphere_faces,lh_sphere_verts,labels,cmap)

%% rotate

% function [ rotatedParc , rotatedMask] = rotate_sphere_parc( iParcels, iSphere , iMask, ithetas)
rotParc = rotate_sphere_parc(labels,lh_sphere_verts,blackHoleMask) ;

% and viz
figure
quick_plot_surf(lh_sphere_faces,lh_sphere_verts,rotParc,cmap)

%% figure out which labs are in black, and need to be repositioned

% function [ labelsToReSeed ] = eval_medial_space(origMask,rotVals,spaceVal)
fillVals = eval_medial_space(blackHoleMask,rotParc,1,'spearman') ;

%% make new annot with rotated black hole filled

newBlackHoleInd = rotParc == blackHoleVal ;
% get only new blackHole outside of old black hole
%  by multipling by old backHole converse
newBlackHoleInd = newBlackHoleInd .* ~blackHoleMask ;

newBlackHoleCoors = lh_sphere_verts(logical(newBlackHoleInd),:) ;

% function [ filledVals ] = kfill_space(fillVals,toFillCoords,initPrcnt) 
fVals4BlackHole = kfill_space(fillVals,newBlackHoleCoors) ;

% write into newParc var
newParc = rotParc .* 1 ;

% all fill vals we 'pop' because they'll be moved to new place
newParc(logical(sum(bsxfun(@eq,newParc,fillVals'),2))) = blackHoleVal ;

% now put the new labs into the parc
newParc(logical(newBlackHoleInd)) = fVals4BlackHole ;
newParc = newParc .* ~blackHoleMask ;

%% viz new rotated parc

figure
quick_plot_surf(lh_sphere_faces,lh_sphere_verts,newParc,cmap)




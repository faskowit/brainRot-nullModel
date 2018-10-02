%% clear stuff
clc
clearvars

%% setup paths

addpath(genpath(pwd))
addpath([ getenv('FREESURFER_HOME') 'matlab'])
addpath(genpath('../plotFSurf2'))

%% load some data

lh_sphere = [ pwd '/data/external/fsaverage/surf/lh.sphere' ] ;
rh_sphere = [ pwd '/data/external/fsaverage/surf/rh.sphere' ] ;
lh_inflated = [ pwd '/data/external/fsaverage/surf/lh.inflated' ] ;
rh_inflated = [ pwd '/data/external/fsaverage/surf/rh.inflated' ] ;

% setup struct
surfSphereData = struct();
surfInflateData = struct();

% func to read data into struct, will get surfData.LH and surfDace.RH
surfSphereData = read_surfStruct(lh_sphere,'LH',surfSphereData) ;
surfSphereData = read_surfStruct(rh_sphere,'RH',surfSphereData) ;

% func to read data into struct, will get surfData.LH and surfDace.RH
surfInflateData = read_surfStruct(lh_inflated,'LH',surfInflateData) ;
surfInflateData = read_surfStruct(rh_inflated,'RH',surfInflateData) ;

%% read in annot
% setup struct
annotData = struct();

lh_annot = [ pwd '/data/external/fsaverage/label/lh.aparc.a2009s.annot' ] ;
rh_annot = [ pwd '/data/external/fsaverage/label/rh.aparc.a2009s.annot' ] ;

% func to read data into struct
annotData = read_annotStruct(lh_annot,'LH',annotData) ;
annotData = read_annotStruct(rh_annot,'RH',annotData) ;

% get the total number of rois, which we just need to read as the height of
% either of the annot color tables
annotData.nrois = size(annotData.LH.ct.table,1) ;

% the unique ids for each
annotData.roi_ids = annotData.LH.ct.table(:,5) ;

annotData.LH.vals = set_roi_vals(annotData.LH.labs,annotData.roi_ids,1:annotData.nrois) ;
annotData.RH.vals = set_roi_vals(annotData.RH.labs,annotData.roi_ids,1:annotData.nrois) ;

%% get the i mask

blackVal = 1 ;

% get where midline 'black hole' is
iMask_LH = (annotData.LH.vals == blackVal) ; 

cmap = annotData.LH.ct.table(:,1:3) ./ 255 ;

%% viz before

figure
h = viz_views(surfSphereData,annotData.LH.vals,[],'lh:med') ;
% add the colormap
colormap(cmap)
lighting none

figure
h = viz_views(surfSphereData,annotData.LH.vals,[],'lh:lat') ;
% add the colormap
colormap(cmap)
lighting none

%% rotate

% function [ rotatedParc , rotatedMask] = rotate_sphere_parc( iParcels, iSphere , iMask, ithetas)
[ rotParc , rotMask ] = rotate_sphere_parc(annotData.LH.vals,surfSphereData.LH,iMask_LH) ;

figure
h = viz_views(surfSphereData,rotParc,[],'lh:med') ;
% add the colormap
colormap(cmap)
lighting none
figure
h = viz_views(surfSphereData,rotParc,[],'lh:lat') ;
% add the colormap
colormap(cmap)
lighting none

%% figure out which labs are in black, and need to be repositioned

% function [ labelsToReSeed ] = eval_medial_space(origMask,rotVals,spaceVal)
fillVals = eval_medial_space(iMask_LH,rotParc,1) ;

%% fill the hole

% now get the new black hole
newBlackHoleInd = rotParc == blackVal ;
% get only new blackHole outside of old black hole
%  by multipling by old backHole converse
newBlackHoleInd = newBlackHoleInd .* ~iMask_LH ;

newBlackHoleCoors = surfSphereData.LH.coords(~~newBlackHoleInd,:) ;

% function [ filledVals ] = kfill_space(fillVals,toFillCoords,initPrcnt) 
fVals = kfill_space(fillVals,newBlackHoleCoors) ;

newParc = rotParc .* 1 ;
% now put the new labs into the parc
newParc(~~newBlackHoleInd) = fVals ;
newParc = newParc .* ~iMask_LH ;

%%

figure
h = viz_views(surfSphereData,newParc,[],'lh:lat') ;
% add the colormap
colormap(cmap)
lighting none

figure
h = viz_views(surfSphereData,newParc,[],'lh:med') ;
% add the colormap
colormap(cmap)
lighting none





















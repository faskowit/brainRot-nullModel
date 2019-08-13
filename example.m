%% clear stuff
clc
clearvars
close all

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
% lets make it a little bit more readable
cmap(1,:) = [ 1 1 1 ]; 

%% get the medial wall, i.e. the 'black hole', created by subcortical and 
% callosal structures

% this is the value it will be in 'labels' var
medialWallVal = 1 ;

% get the 'black hole' area
medialWallMask = (labels == medialWallVal) ; 

%% viz before
% this is the original parcellation, we haven't done anything to it yet

figure
quick_plot_surf(lh_sphere_faces,lh_sphere_verts,labels,cmap)

%% rotate the parcellation

rng(4242)

% function [ rotatedParc , rotatedMask] = rotate_sphere_parc( iParcels, iSphere , iMask)
rotParc = rotateuniform_sphere_parc(labels,lh_sphere_verts,medialWallMask) ;

% and viz
figure
quick_plot_surf(lh_sphere_faces,lh_sphere_verts,rotParc,cmap)

%% visualize the area we need to cut out

tmp = medialWallMask .* (ones(length(medialWallMask),1) .* max(rotParc+1));
needToCutout = (rotParc .* ~medialWallMask) + tmp ;

% and viz
figure
quick_plot_surf(lh_sphere_faces,lh_sphere_verts,needToCutout,[ cmap ; 0.75 0.75 0.75 ])

%% figure out which labs are in medial wall, and need to be repositioned

% function labelsToReSeed = eval_medial_space(origMask,rotVals,spaceVal)
fillVals = eval_medial_space(medialWallMask,rotParc,medialWallVal,'chebychev') ;

%% make new annot with rotated black hole filled

% function newParc = get_null_parc_wFilled(origParc,rotParc,medialWallVal,fillVals,surfCoords)
newParc = get_null_parc_wFilled(labels,rotParc,medialWallVal,fillVals,lh_sphere_verts) ;

% viz new rotated parc
figure
quick_plot_surf(lh_sphere_faces,lh_sphere_verts,newParc,cmap)

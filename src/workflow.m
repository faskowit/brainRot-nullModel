clc
clearvars

%%

cd('/home/jfaskowi/JOSHSTUFF/projects/nulloverlaps')
addpath(genpath([pwd '/src']))
addpath(genpath('/home/jfaskowi/JOSHSTUFF/software/FS_6p0/freesurfer/matlab/')) 
addpath(genpath('~/JOSHSTUFF/scripts/BCT/'))
addpath(genpath('/home/jfaskowi/JOSHSTUFF/projects/plotFSurf2'))

%% read in a sphere

FREESURFER_DIR = '/home/jfaskowi/JOSHSTUFF/software/FS_6p0/freesurfer/' ;

lh_sphere = [ FREESURFER_DIR '/subjects/fsaverage/surf/lh.sphere' ] ;
rh_sphere = [ FREESURFER_DIR '/subjects/fsaverage/surf/rh.sphere' ] ;

% setup struct
surfData = struct();

% func to read data into struct, will get surfData.LH and surfDace.RH
surfData = read_surfStruct(lh_sphere,'LH',surfData) ;
surfData = read_surfStruct(rh_sphere,'RH',surfData) ;

%% read in annot
% setup struct
annotData = struct();

lh_annot = '/home/jfaskowi/JOSHSTUFF/projects/yeo17dil/lh.yeo17dil.annot' ;
rh_annot = '/home/jfaskowi/JOSHSTUFF/projects/yeo17dil/rh.yeo17dil.annot' ;

    % func to read data into struct
annotData = read_annotStruct(lh_annot,'LH',annotData) ;
annotData = read_annotStruct(rh_annot,'RH',annotData) ;

% get the total number of rois, which we just need to read as the height of
% either of the annot color tables
annotData.nrois = size(annotData.LH.ct.table,1) ;

% the unique ids for each
annotData.roi_ids = annotData.LH.ct.table(:,5) ;

%% plot struct
% setup struct
plotData_annot = struct ;

% set unknown value
plotData_annot.wei_unkn = -1 ;

plotData_annot.LH.wei = set_roi_vals(annotData.LH.labs,annotData.roi_ids,1:annotData.nrois) ;
plotData_annot.RH.wei = set_roi_vals(annotData.RH.labs,annotData.roi_ids,1:annotData.nrois) ;
     
%% read medial wall

lh_medial_lab = [ FREESURFER_DIR '/subjects/fsaverage/label/lh.Medial_wall.label' ] ;
rh_medial_lab = [ FREESURFER_DIR '/subjects/fsaverage/label/rh.Medial_wall.label' ] ;

lh_medial = read_label_fn(lh_medial_lab) ;
rh_medial = read_label_fn(rh_medial_lab) ;

lh_mask = ones(length(annotData.LH.verts),1) ;
lh_mask(lh_medial(:,1)) = 0 ;

rh_mask = ones(length(annotData.RH.verts),1) ;
rh_mask(rh_medial(:,1)) = 0 ;

%%

figure
h = viz_views(surfData,plotData_annot.LH.wei,plotData_annot.RH.wei,'lh:lat') ;

% add the colormap
colormap(annotData.LH.ct.table(:,1:3) ./ 255)

%% try out the rotation

% function [ nullpar, moved ]= generate_null_model( parcels, sphere, mask )
nullpar = generate_rotate_null_parc( plotData_annot.LH.wei , ...
   surfData.LH ) ; 


%%

figure
h = viz_views(surfData,nullpar,plotData_annot.RH.wei,'lh:med') ;

% add the colormap
colormap(annotData.LH.ct.table(:,1:3) ./ 255)


%%

figure
h = viz_views(surfData,lh_s125_vals,plotData_annot.RH.wei,'lh:med') ;

% add the colormap
colormap([0 0 0 ;brewermap(90,'spectral')])





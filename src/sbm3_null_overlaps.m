%% load data for wsbm models

% aaa = load('/home/jfaskowi/JOSHSTUFF/projects/sbm3/data/processed/scale125_both_normalpoisson_a0p5_basicData_v7p3.mat')

scale125 = load('/home/jfaskowi/JOSHSTUFF/projects/sbm3/data/interim/scale125_both_normalpoisson_a0p5_comVecs.mat')
yeo = load('/home/jfaskowi/JOSHSTUFF/projects/sbm3/data/interim/yeo_both_normalpoisson_a0p5_comVecs.mat')

%% load the annotation

% function [vertices, label, colortable] = read_annotation(filename, varargin)
[ ~ , lh_s125_lab , lh_s125_ct ] = read_annotation('/home/jfaskowi/JOSHSTUFF/sandbox/lausanne_fsaverage/lh.myatlas125.annot') ;
[ ~ , rh_s125_lab , rh_s125_ct ] = read_annotation('/home/jfaskowi/JOSHSTUFF/sandbox/lausanne_fsaverage/rh.myatlas125.annot') ;

% plotData_annot.LH.wei = set_roi_vals(annotData.LH.labs,annotData.roi_ids,1:annotData.nrois) ;
lh_s125_vals = set_roi_vals(lh_s125_lab,lh_s125_ct.table(:,5),1:lh_s125_ct.numEntries) ;
rh_s125_vals = set_roi_vals(rh_s125_lab,rh_s125_ct.table(:,5),1:rh_s125_ct.numEntries) ;

[ ~ , lh_yeo_lab , lh_yeo_ct ] = read_annotation('/home/jfaskowi/JOSHSTUFF/projects/yeo17dil/lh.yeo17dil.annot') ;
[ ~ , rh_yeo_lab , rh_yeo_ct ] = read_annotation('/home/jfaskowi/JOSHSTUFF/projects/yeo17dil/rh.yeo17dil.annot') ;

lh_yeo_vals = set_roi_vals(lh_yeo_lab,lh_yeo_ct.table(:,5),1:lh_yeo_ct.numEntries) ;
rh_yeo_vals = set_roi_vals(rh_yeo_lab,rh_yeo_ct.table(:,5),1:rh_yeo_ct.numEntries) ;

%% do the actual comparison 

% left hemi
surfSize = length(lh_yeo_vals) ;
lh_yeo_wsbm_comstruct = zeros(surfSize,1) ;
lh_yeo_mod_comstruct = zeros(surfSize,1) ;

for idx = 2:58
   lh_yeo_wsbm_comstruct(lh_yeo_vals==idx) = yeo.comVecs.wsbm(idx-1) ;
   lh_yeo_mod_comstruct(lh_yeo_vals==idx) = yeo.comVecs.mod(idx-1) ;
end

lh_s125_wsbm_comstruct = zeros(surfSize,1) ;
lh_s125_mod_comstruct = zeros(surfSize,1) ;

for idx = 2:112
    lh_s125_wsbm_comstruct(lh_s125_vals==idx) = scale125.comVecs.wsbm(idx-1);
    lh_s125_mod_comstruct(lh_s125_vals==idx) = scale125.comVecs.mod(idx-1);
end

% right hemi
surfSize = length(rh_yeo_vals) ;

rh_yeo_wsbm_comstruct = zeros(surfSize,1) ;
rh_yeo_mod_comstruct = zeros(surfSize,1) ;

for idx = 59:115
   rh_yeo_wsbm_comstruct(rh_yeo_vals==idx) = yeo.comVecs.wsbm(idx-1) ;
   rh_yeo_mod_comstruct(rh_yeo_vals==idx) = yeo.comVecs.mod(idx-1) ;
end

rh_s125_wsbm_comstruct = zeros(surfSize,1) ;
rh_s125_mod_comstruct = zeros(surfSize,1) ;

for idx = 113:219
    rh_s125_wsbm_comstruct(rh_s125_vals==idx) = scale125.comVecs.wsbm(idx-1);
    rh_s125_mod_comstruct(rh_s125_vals==idx) = scale125.comVecs.mod(idx-1);
end

% for lausanne
% right hemisphere 108 for real, but only 107 (2:108 used)
% left hemisphere 111 for real, got 111 (116:226)

%% empirical differences

[lh_wsbm_emp_vi,lh_wsbm_emp_nmi] = partition_distance(lh_yeo_wsbm_comstruct(~~lh_mask),lh_s125_wsbm_comstruct(~~lh_mask)) ;
[rh_wsbm_emp_vi,rh_wsbm_emp_nmi] = partition_distance(rh_yeo_wsbm_comstruct(~~rh_mask),rh_s125_wsbm_comstruct(~~rh_mask)) ;

[lh_mod_emp_vi,lh_mod_emp_nmi] = partition_distance(lh_yeo_mod_comstruct(~~lh_mask),lh_s125_mod_comstruct(~~lh_mask)) ;
[rh_mod_emp_vi,rh_mod_emp_nmi] = partition_distance(rh_yeo_mod_comstruct(~~rh_mask),rh_s125_mod_comstruct(~~rh_mask)) ;

[combo_wsbm_emp_vi,combo_wsbm_emp_nmi] = partition_distance(...
    [ lh_yeo_wsbm_comstruct(~~lh_mask) ; rh_yeo_wsbm_comstruct(~~rh_mask) ], ...
    [ lh_s125_wsbm_comstruct(~~lh_mask) ; rh_s125_wsbm_comstruct(~~rh_mask) ] ) ;
[combo_mod_emp_vi,combo_mod_emp_nmi] = partition_distance(...
    [ lh_yeo_mod_comstruct(~~lh_mask) ; rh_yeo_mod_comstruct(~~rh_mask) ], ...
    [ lh_s125_mod_comstruct(~~lh_mask) ; rh_s125_mod_comstruct(~~rh_mask) ] ) ;

combo_wsbm_emp_rand = adjrand(...
    [ lh_yeo_wsbm_comstruct(~~lh_mask) ; rh_yeo_wsbm_comstruct(~~rh_mask) ], ...
    [ lh_s125_wsbm_comstruct(~~lh_mask) ; rh_s125_wsbm_comstruct(~~rh_mask) ] ) ;
combo_mod_emp_rand = adjrand(...
    [ lh_yeo_mod_comstruct(~~lh_mask) ; rh_yeo_mod_comstruct(~~rh_mask) ], ...
    [ lh_s125_mod_comstruct(~~lh_mask) ; rh_s125_mod_comstruct(~~rh_mask) ] ) ;


%% now time for randomization

% numNulls = 5000 ;
% rh_null_dist_wsbm = zeros(numNulls,2) ;
% rh_null_dist_mod = zeros(numNulls,2) ;
% lh_null_dist_wsbm = zeros(numNulls,2) ;
% lh_null_dist_mod = zeros(numNulls,2) ;
% 
% combo_null_dist_wsbm = zeros(numNulls,2) ;
% combo_null_dist_mod = zeros(numNulls,2) ;
% combo_rand_wsbm = zeros(numNulls,1);
% combo_rand_mod = zeros(numNulls,1);

for idx = 1:numNulls
    
    disp(idx)

    rotate_rh = randi([-90, 90],1,3) ;
    rotate_lh = randi([-90, 90],1,3) ;
    
    % function [ nullpar , nullmask] = generate_rotate_null_parc( parcels, sphere , mask, ithetas)

    % LH
    
     % WSBM
    [lh_wsbm_null,lh_tmp_mask] = generate_rotate_null_parc(lh_s125_wsbm_comstruct,surfData.LH,lh_mask,rotate_lh) ;
    lh_tmp_mask = lh_tmp_mask .* lh_mask ;
    [lh_null_dist_wsbm(idx,1),lh_null_dist_wsbm(idx,2)] = partition_distance(lh_yeo_wsbm_comstruct(~~lh_tmp_mask),lh_wsbm_null(~~lh_tmp_mask)) ;
    
    % MOD
    [lh_mod_null,~] = generate_rotate_null_parc(lh_s125_mod_comstruct,surfData.LH,lh_mask,rotate_lh) ;
%     tmp_mask = tmp_mask .* lh_mask ;
    [lh_null_dist_mod(idx,1),lh_null_dist_mod(idx,2)] = partition_distance(lh_yeo_mod_comstruct(~~lh_tmp_mask),lh_mod_null(~~lh_tmp_mask)) ;   
    
    % RH
    
    % WSBM
    [rh_wsbm_null,rh_tmp_mask] = generate_rotate_null_parc(rh_s125_wsbm_comstruct,surfData.RH,rh_mask,rotate_rh) ;
    rh_tmp_mask = rh_tmp_mask .* rh_mask ;
    [rh_null_dist_wsbm(idx,1),rh_null_dist_wsbm(idx,2)] = partition_distance(rh_yeo_wsbm_comstruct(~~rh_tmp_mask),rh_wsbm_null(~~rh_tmp_mask)) ;
    
    % MOD
    [rh_mod_null,~] = generate_rotate_null_parc(rh_s125_mod_comstruct,surfData.RH,rh_mask,rotate_rh) ;
%     rh_tmp_mask = rh_tmp_mask .* rh_mask ;
    [rh_null_dist_mod(idx,1),rh_null_dist_mod(idx,2)] = partition_distance(rh_yeo_mod_comstruct(~~rh_tmp_mask),rh_mod_null(~~rh_tmp_mask)) ;
        
    % combo compare
    [ combo_null_dist_wsbm(idx,1) , combo_null_dist_wsbm(idx,2) ] = partition_distance(...
        [ lh_wsbm_null(~~lh_tmp_mask) ; rh_wsbm_null(~~rh_tmp_mask) ] , ...
        [ lh_yeo_wsbm_comstruct(~~lh_tmp_mask) ; rh_yeo_wsbm_comstruct(~~rh_tmp_mask) ] ) ;
    
    [ combo_null_dist_mod(idx,1) , combo_null_dist_mod(idx,2) ] = partition_distance(...
        [ lh_mod_null(~~lh_tmp_mask) ; rh_mod_null(~~rh_tmp_mask) ] , ...
        [ lh_yeo_mod_comstruct(~~lh_tmp_mask) ; rh_yeo_mod_comstruct(~~rh_tmp_mask) ] ) ;
   
    combo_rand_wsbm(idx) = adjrand( ...
        [ lh_wsbm_null(~~lh_tmp_mask) ; rh_wsbm_null(~~rh_tmp_mask) ] , ...
        [ lh_yeo_wsbm_comstruct(~~lh_tmp_mask) ; rh_yeo_wsbm_comstruct(~~rh_tmp_mask) ] ) ;
    
    combo_rand_mod(idx) = adjrand( ...
        [ lh_mod_null(~~lh_tmp_mask) ; rh_mod_null(~~rh_tmp_mask) ] , ...
        [ lh_yeo_mod_comstruct(~~lh_tmp_mask) ; rh_yeo_mod_comstruct(~~rh_tmp_mask) ] ) ;
end

%% view it

default_cmap = [0    0.4470    0.7410 ;
                0.8500    0.3250    0.0980 ] ;

% VI FIGURE

figure
set(gcf, 'Units', 'Normalized', 'Position', [0.2, 0.2, 0.4, 0.5]);

histogram(combo_null_dist_wsbm(:,1),'BinWidth',0.0025,...
    'Normalization','probability','FaceAlpha',0.25,'EdgeAlpha',0.01)
hold
histogram(combo_null_dist_mod(:,1),'BinWidth',0.0025,...
    'Normalization','probability','FaceAlpha',0.25,'EdgeAlpha',0.01)

xlim([0.18 0.31])
ylimits = ylim ;
ylim([ ylimits(1) ylimits(2) * 1.50])

ylimits = ylim ;

plot([combo_wsbm_emp_vi combo_wsbm_emp_vi],...
    [ylimits(1) ylimits(2)*0.95],...
    'Color',[ default_cmap(1,:) 0.8],'LineWidth',1)

plot([combo_mod_emp_vi combo_mod_emp_vi],...
    [ylimits(1) ylimits(2)*0.95],...
    'Color',[ default_cmap(2,:) 0.8],'LineWidth',1)

set(gca,'FontSize',12) 

lg = legend('WSBM null','Modular null','WSBM emp','Modular emp') ;
lg.FontSize = 16 ;

% RAND

figure
set(gcf, 'Units', 'Normalized', 'Position', [0.2, 0.2, 0.4, 0.5]);


histogram(combo_rand_wsbm,'BinWidth',0.003,'Normalization',...
    'probability','FaceAlpha',0.25,'EdgeAlpha',0.01)
hold
histogram(combo_rand_mod,'BinWidth',0.003,'Normalization',...
    'probability','FaceAlpha',0.25,'EdgeAlpha',0.01)

% xlim([0.18 0.31])
ylimits = ylim ;
ylim([ ylimits(1) ylimits(2) * 1.250])

ylimits = ylim ;

plot([combo_wsbm_emp_rand combo_wsbm_emp_rand],...
    [ylimits(1) ylimits(2)*0.95],...
    'Color',[ default_cmap(1,:) 0.8],'LineWidth',1)

plot([combo_mod_emp_rand combo_mod_emp_rand],...
    [ylimits(1) ylimits(2)*0.95],...
    'Color',[ default_cmap(2,:) 0.8],'LineWidth',1)

set(gca,'FontSize',12) 

% lg = legend('WSBM null','Modular null','WSBM emp','Modular emp') ;
% lg.FontSize = 16 ;

%%

annotData2 = struct();

lh_annot = '/home/jfaskowi/JOSHSTUFF/sandbox/lausanne_fsaverage/lh.myatlas125.annot' ;
rh_annot = '/home/jfaskowi/JOSHSTUFF/sandbox/lausanne_fsaverage/rh.myatlas125.annot' ;

    % func to read data into struct
annotData2 = read_annotStruct(lh_annot,'LH',annotData2) ;
annotData2 = read_annotStruct(rh_annot,'RH',annotData2) ;

% get the total number of rois, which we just need to read as the height of
% either of the annot color tables
annotData2.nrois = size(annotData2.LH.ct.table,1) ;

% the unique ids for each
annotData2.roi_ids = annotData2.LH.ct.table(:,5) ;

plotData2 = struct() ;
% set unknown value
plotData2.wei_unkn = -1 ;

plotData2.LH.wei = set_roi_vals(annotData2.LH.labs,annotData2.roi_ids,1:annotData2.nrois) ;
plotData2.RH.wei = set_roi_vals(annotData2.RH.labs,annotData2.roi_ids,1:annotData2.nrois) ;

FREESURFER_DIR = '/home/jfaskowi/JOSHSTUFF/software/FS_6p0/freesurfer/' ;

lh_inflate = [ FREESURFER_DIR '/subjects/fsaverage/surf/lh.inflated' ] ;
rh_inflate = [ FREESURFER_DIR '/subjects/fsaverage/surf/rh.inflated' ] ;

% setup struct
surfData2 = struct();

% func to read data into struct, will get surfData.LH and surfDace.RH
surfData2 = read_surfStruct(lh_inflate,'LH',surfData2) ;
surfData2 = read_surfStruct(rh_inflate,'RH',surfData2) ;

figure
h = viz_views(surfData2,lh_s125_wsbm_comstruct,rh_s125_wsbm_comstruct,'all','direct') ;
colormap(brewermap(12,'paired'))
title('wsbm')

figure
h = viz_views(surfData2,lh_s125_mod_comstruct,rh_s125_mod_comstruct,'all','direct') ;
colormap(brewermap(12,'paired'))
title('mod')


%%
figure
h = viz_views(surfData2,lh_yeo_wsbm_comstruct,rh_yeo_wsbm_comstruct,'all','direct') ;
colormap(brewermap(12,'paired'))
title('wsbm')

figure
h = viz_views(surfData2,lh_yeo_mod_comstruct,rh_yeo_mod_comstruct,'all','direct') ;
colormap(brewermap(12,'paired'))
title('mod')

%% 


[a,b] = partition_distance([ lh_mod_null(~~lh_tmp_mask) ; rh_mod_null(~~rh_tmp_mask) ] , ...
        [ lh_yeo_mod_comstruct(~~lh_tmp_mask) ; rh_yeo_mod_comstruct(~~rh_tmp_mask) ] ) ;

[aa] = adjrand([ lh_mod_null(~~lh_tmp_mask) ; rh_mod_null(~~rh_tmp_mask) ] , ...
        [ lh_yeo_mod_comstruct(~~lh_tmp_mask) ; rh_yeo_mod_comstruct(~~rh_tmp_mask) ] ) ;

%%

%%
figure
h = viz_views(surfData2,plotData_annot.LH.wei,plotData_annot.RH.wei,'lh:lat') ;
colormap(annotData.LH.ct.table(:,1:3) ./ 255)



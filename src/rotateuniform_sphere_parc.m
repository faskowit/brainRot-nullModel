function [ rotatedParc , rotatedMask, knnIDX] = rotateuniform_sphere_parc( iParcels, iSphere , iMask)
%GENERATE_NULL_MODEL Generate a null model (parcellations).
%
%   INPUT
%   =====
%   iParcels: A parcellation; label data from annotation file
%   iSphere: A spherical surface model, with sphere.coors field
%   iMask: (optional): mask that will rotate same way
%
%   OUTPUT
%   ======
%   rotatedParc: A randomly rotated parcellation
%   rotatedMask: the mask rotated in same way
%   knnIDX:      the new indices for the rotation
%
%   REFERENCE
%   =========
%   This code is adapted from the evaluation pipelines described in the 
%   brain parcellation survey, "Human Brain Mapping: A Systematic 
%   Comparison of Parcellation Methods for the Human Cerebral Cortex", 
%   NeuroImage, 2017 doi.org/10.1016/j.neuroimage.2017.04.014 
%
%   For the parcellation data and reference manual visit the survey page: 
%   https://biomedia.doc.ic.ac.uk/brain-parcellation-survey/ 
%
%   Author: Salim Arslan, April 2017 (name.surname@imperial.ac.uk)
%
% j faskowitz edit
%
% UNIFORM rotation update from Alexander-Bloch & Siyuan Liu
%   https://github.com/spin-test/spin-test
%   using a different way to apply rotation that is unbiased in direction
%   sampled
%

if ~exist('iMask','var') || isempty(iMask)
   iMask = [] ;
   rotatedMask = [] ;
end

if ~isfield(iSphere,'coords')
   if size(iSphere,2) == 3
       disp('assuming iSphere is coords')
       tmp = struct() ;
       tmp.coords = iSphere .* 1 ;
       iSphere = tmp ;
   else
       error('need sphere with field "coords" for this func to work')
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% uniform sampling update
% code from https://github.com/spin-test/spin-test/blob/master/scripts/SpinPermuFS.m#L64
A = normrnd(0,1,3,3);
[rot, temp] = qr(A);
rot = rot * diag(sign(diag(temp)));
if(det(rot)<0)
    rot(:,1) = -rot(:,1);
end 
    
% r_x = rotx(thetas(1)) ;
% r_y = roty(thetas(2)) ;
% r_z = rotz(thetas(3)) ;

% rotated coords
rotatedCoords = ( iSphere.coords * rot ) ;
% IDX = KNNSEARCH(X,Y)
% Each row in IDX contains the index of the nearest neighbor in X for the 
% corresponding row in Y.
knnIDX = knnsearch(iSphere.coords,rotatedCoords);
% get rotated parcellation
rotatedParc = iParcels(knnIDX);
% if mask provided, get a rotated masked too
if ~isempty(iMask)
    rotatedMask = iMask(knnIDX);
end

end % end main

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper funcs

% ROTX	Rotation about X axis
%
%	ROTX(theta) returns a homogeneous transformation representing a 
%	rotation of theta about the X axis.
%
%	See also ROTY, ROTZ, ROTVEC.
%
% 	Copyright (C) Peter Corke 1990
function r = rotx(t)
t = deg2rad(t);
ct = cos(t);
st = sin(t);
r =    [1	0	0	0
    0	ct	-st	0
    0	st	ct	0
    0	0	0	1];
end
    
% ROTY	Rotation about Y axis
function r = roty(t)
t = deg2rad(t);
ct = cos(t);
st = sin(t);
r =    [ct	0	st	0
    0	1	0	0
    -st	0	ct	0
    0	0	0	1];
end   

% ROTZ	Rotation about Z axis
function r = rotz(t)
t = deg2rad(t);
ct = cos(t);
st = sin(t);
r =    [ct	-st	0	0
    st	ct	0	0
    0	0	1	0
    0	0	0	1];
end

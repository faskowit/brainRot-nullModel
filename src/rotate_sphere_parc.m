function [ rotatedParc , rotatedMask] = rotate_sphere_parc( iParcels, iSphere , iMask, ithetas)
%GENERATE_NULL_MODEL Generate a null model (parcellations).
%
%   INPUT
%   =====
%   iParcels: A parcellation; label data from annotation file
%   iSphere: A spherical surface model, with sphere.coors field
%   iMask: (optional): mask that will rotate same way
%   ithetas: (optional): input roation angles [ xDeg yDeg zDeg ]
%
%   OUTPUT
%   ======
%   rotatedParc: A randomly rotated parcellation
%   rotatedMask: the mask rotated in same way
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

if ~exist('iMask','var') || isempty(iMask)
   iMask = [] ;
   rotatedMask = [] ;
end

if ~exist('iThetas','var') || isempty(ithetas) 
   thetas = randi([30, 150],1,3); % The range of rotations
else
   thetas = ithetas ; 
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

r_x = rotx(thetas(1)) ;
r_y = roty(thetas(2)) ;
r_z = rotz(thetas(3)) ;

% rotated coords
rotatedCoords = ( iSphere.coords * ...
                r_x(1:3,1:3) * ...
                r_y(1:3,1:3) * ...
                r_z(1:3,1:3) ) ;
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

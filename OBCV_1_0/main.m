%% Step 0: read file (point cloud & local feature size if possible), and
clear;clc;close all;
path('toolbox',path);
extension='.off';
filename = '..\data\3-2-1.58-25';

tic
P.filename = [filename extension];% point set
[P.pts,P.faces, P.normal1] = read_mesh(P.filename);
% write_xyz('out.xyz',P.pts,[]);
P.npts = size(P.pts,1);
P.pts = GS.normalize(P.pts);
[P.bbox, P.diameter] = GS.compute_bbox(P.pts);
disp(sprintf('read point set:'));
toc

[P outfilename]= contraction(P);
P = visibility_by_pts(P, outfilename);
P = normal_smoothing(P, outfilename);
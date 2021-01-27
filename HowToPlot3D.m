%% Instructions to plot 3D model in MATLAB
% Author: Julian Guinane
% Created: 27/01/2021
% This sample script shows how to plot a 3D model initiall given as an STL
% file and transform it with a given pose and heading

% MIT License
% 
% Copyright (c) 2021 Julian-Guinane
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

%% Housekeeping
clear;
clc;
close all;

%% Import 3D model
% Easiest to generate an STL file (can export as STL in Solidworks and bump
% the coarseness up so the geometry is fairly simple)

% Install STLREAD from MATLAB File Exchange
% (https://au.mathworks.com/matlabcentral/fileexchange/22409-stl-file-reader)
% Wherever you install it you need to rename it because MATLAB already has
% a stlread function. I have renamed mine stlread_2
filename = 'model.stl';
[model.faces, model.vertices] = stlread_2(filename);

% Because of the NED coord system, we need to flip some axes. Will also
% centre the model...
model.vertices = model.vertices(:, [3,1,2]);
model.vertices(:,3) = -model.vertices(:,3);
model.vertices(:,2) = -model.vertices(:,2);
centroid = (max(model.vertices) + min(model.vertices))/2;
model.vertices = model.vertices - centroid;

% Note: I would normally save the converted stl data and read it as a .mat
% file as this is quicker once you have done the initial conversion. I have
% commmented out the method below:
% save('model.mat', 'model');
% Then you would load the model as:
% load('model.mat', 'model');

%% Initial plot

% Set up your figure, easiest to store the figure handle in a struct as
% there are other variables we need to keep to apply our transform later
f.fig = figure;
f.ax = gca;
axis equal;
set(f.ax, 'Zdir', 'reverse'); % Assuming NED coords, need to flip z,y axes
set(f.ax, 'Ydir', 'reverse');
f.hg = hgtransform('Parent', f.ax); % hgtansform is used to transform model

% Plot initial model
model.Parent = f.hg;
model.EdgeColor = 'none';
model.FaceVertexCData = copper(size(model.vertices, 1)); % Get colormap, search Colormap for list
model.FaceColor = 'interp';
model.FaceLighting = 'gouraud';
model.AmbientStrength = 0.15;
patch(model)

%% Transform plot
% You would put this section at the end of your loop/every time you want to
% update your plot

pose = [100, 100, -100]; % Whatever your cartesion coords are in NED
quat = [0.6547, 0.4364, 0.4364, 0.4364]; % Whatever your quaternion is in NED

% Get transformation matrices
translate = makehgtform('translate', pose);
axang = quat2axang(quat);
rotate = makehgtform('axisrotate', axang(1:3), axang(4));

% Apply transform to model
set(f.hg, 'Matrix', translate*rotate);
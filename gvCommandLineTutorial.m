%% GIMBL-Vis Matlab Command Line Interface Tutorial
% This is a tutorial explaining the command line interface for GIMBL-Vis (using 
% the Matlab command window).
%
% For a tutorial on the easier-to-use graphical interface, see the slides at:
%   http://www.earoberts.com/GIMBL-Vis-Docs/slides.html


%% Setup

% Format
format compact

% Check if in gimbl-vis folder
if ~exist(fullfile('.','gvTutorial.m'), 'file')
  error('Current folder should be the gimbl-vis folder in order to run this code block.')
end

% Add gv toolbox to Matlab path if needed
if ~exist('gv','class')
  addpath(genpath(pwd));
end

%% Basics
sampleData = cat(3, magic(20), magic(20));
axis_vals = {1:20, 1:20,{'type1','type2'}};
axis_names = {'x','y','dataType'};

hypercubeName = 'sampleDataset';

sampleGvArray = gvArray(sampleData, axis_vals, axis_names);
sampleGvArray.meta.defaultHypercubeName = hypercubeName;

gvFile = 'gvSampleFile.mat';

% 4 ways to use the gv constructor method (ie the class name as a function):
%   1) Create empty gv object
gvObj = gv();
gvObj.summary;

%   2) Call load method on file/dir. If dir, must have only 1 mat file. File can
%   store a gv, gvArray, or MDD object.
% gvObj = gv(gvFile);
% gvObj.summary;
% 
% gvObj = gv(gvFile, hypercubeName);
% gvObj.summary;


%   3) Call gvArray constructor on gvArray/MDD data
gvObj = gv(sampleGvArray);
gvObj.summary;
gvObj.printHypercubeList;

gvObj = gv(hypercubeName, sampleGvArray);
gvObj.printHypercubeList;
%
%   4) Call gvArray constructor on cell/numeric array data. Can be linear
%         or multidimensional array data.
gvObj = gv(sampleData);
gvObj.summary;

gvObj = gv(hypercubeName, sampleData);
gvObj.summary;

gvObj = gv(sampleData, axis_vals, axis_names);
gvObj.summary;

gvObj = gv(hypercubeName, sampleData, axis_vals, axis_names);
gvObj.summary;

%% Advanced


%% Dynasim Integration

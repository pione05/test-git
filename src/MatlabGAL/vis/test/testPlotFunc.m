function testPlotFunc
% Test plot and save functions
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% Init
addpath(genpath('../../'));

%% Plot rectangle
close all; clear all; clc;

im = galReadRGBIm('peppers.png');

rectxy = [100, 100, 200, 200];

galShowIm(im);
galPlotRect(rectxy);
galPlotRect(rectxy+50, 'g', 2, '--');


%% Plot text
textStr = 'Hello World!';
textPos = [300, 300];

galPlotText(textStr, textPos)

%% Plot points
pts = [50 50; 100 100; 150 150];
galPlotPts(pts)

%% Plot lines

%% Save figure
saveFile = '/tmp/test.jpg';
galSaveFigure([], saveFile, [], [], 2.0);

saveFile = '/tmp/test.png';
galSaveFigure([], saveFile, [], [], 2.0);

saveFile = '/tmp/test.ppm';
galSaveFigure([], saveFile, [], [], 2.0);

saveFile = '/tmp/test.bmp';
galSaveFigure([], saveFile, [], [], 2.0);




function testShowIm
% Test show image functions
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% Init
addpath(genpath('../../'));

%% Show one image
close all; clear all; clc;
h1 = figure(1);
h2 = figure(2);

im = galReadRGBIm('peppers.png');

galShowIm(im, h1)

%% Show overlay images
h1 = figure(1);
h2 = figure(2);
h3 = figure(3);

im1 = galReadRGBIm('peppers.png');
im2 = galReadRGBIm('football.jpg');

[imHeight, imWidth, ~] = size(im1);
im2 = imresize(im2, [imHeight, imWidth]);

galShowOverlayIms(im1, im2);
galShowOverlayIms(im1, im2, 0.8, h2);


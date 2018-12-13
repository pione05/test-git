function loadModel = stLoadModel(config)
% Load and initialize EdgeBox models
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%%
%% SED and Superpixel configuration
sedModel=load(config.sedModelPath); sedModel=sedModel.model;
sedModel.opts.nThreads = config.sedNThreads;
sedModel.opts.sharpen = config.sedSharpen;
sedModel.opts.multiscale = config.sedMultiscale; 
sedModel.opts.nms = config.sedNms;    %to get orientation / do nms by default 

spOpts = spDetect;
spOpts.nThreads = config.spOptsNThreads;  % number of computation threads
spOpts.k = config.spOptsK;    %128;       % controls scale of superpixels (big k -> big sp)
spOpts.alpha = config.spOptsAlpha;    % relative importance of regularity versus data terms
spOpts.beta = config.spOptsBeta;     % relative importance of edge versus color terms
spOpts.merge = config.spOptsMerge;     % set to small value to merge nearby superpixels at end
spOpts.bounds = config.spOptsBounds;   %0: no bounds indicator; 1: add bounds indicator 

ebOpts = edgeBoxes;
ebOpts.alpha = config.ebOptsAlpha;     % step size of sliding window search
ebOpts.beta  = config.ebOptsBeta;     % nms threshold for object proposals
ebOpts.minScore = config.ebOptsMinScore;  % min score of boxes to detect
ebOpts.maxBoxes = config.ebOptsMaxBoxes;  % max number of boxes to detect

% prepare the return value
loadModel.sedModel = sedModel;
loadModel.spOpts = spOpts;
loadModel.ebOpts = ebOpts;

end


% Script to compile the required MEX binaries for PSTracker
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


[projRootPath, ~, ~] = fileparts(mfilename('fullpath'));

run(fullfile(projRootPath, 'tracker', 'tbdTracking', 'compile_tbd.m'));
run(fullfile(projRootPath, 'tracker', '3rdparty_script', 'calcEdgeBoxScore', 'compile_ebs.m'));
run(fullfile(projRootPath, 'tracker', 'ofhtTracking', 'compile_ofht.m'));


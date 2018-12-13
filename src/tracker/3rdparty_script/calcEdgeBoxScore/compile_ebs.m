function compile_ebs
% Script for compiling the mex files related to calculating edgebox score.
% The mex files compiled by this script do not support multi-thread.
% If you want to enable multi-thread by OpenMP, follow and adapt the compiling
% instruction available in the readme file of Dollar's sedToolbox:
% https://github.com/pdollar/edges
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the MSR-LA Full Rights License [see license.txt]
%


disp('Start edgeBoxScore compiling ...');
warning off;
          
% compile calculating edgebox score
cmd = sprintf('mex %s -g mex/calcEdgeBoxScoreMex.cpp -O -outdir mex ', ...
              'CXXFLAGS="-O3 \$CXXFLAGS"');  
eval(cmd);

%compile edgebox nms
cmd = sprintf('mex %s -g mex/edgesNmsMex.cpp -O -outdir mex ', ...
              'CXXFLAGS="-O3 \$CXXFLAGS"');  
eval(cmd);

disp('edgeBoxScore compiling is done!')

end

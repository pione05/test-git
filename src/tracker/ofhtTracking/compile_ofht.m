function compile_ofht
% Script for compiling the mex files for ofhtTracking
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


disp('Start ofhtTracking compiling ...');
warning off;

% compile module for calculating edgebox score
[~, args] = unix(['pkg-config --cflags --libs openssl']);
cmd = sprintf('mex %s -g mex/mexOFHTHardVoteLS.cpp -I/usr/include/eigen3 -O -outdir mex %s', ...
              'CXXFLAGS="-O3 \$CXXFLAGS"', args);       
try          
    eval(cmd);
catch
    fprintf('Compiling ofhtTracking failed!\n');
    fprintf('    Try to install Eigen3 by "sudo apt install libeigen3-dev".\n');
    fprintf('    Try to install openssl by "sudo apt install libssl-dev".\n');
end

disp('ofhtTracking compiling is done!');

end

function compile_tbd
% Compile all the mex files for tracking-by-detection 
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


disp('Start tbdTracking compiling ...');
warning off;

% compile normal hog feature
cmd = sprintf('mex 3rdparty/features_32d.cc -outdir bin');
eval(cmd);

if verLessThan('matlab', '9.0')
    cmd = sprintf('mex 3rdparty/uninit.c -outdir bin');
else
    cmd = sprintf('mex 3rdparty/uninit_matlab2016.c -outdir bin -output uninit');
end    
eval(cmd);

% compile nmsOverlap
cmd = sprintf('mex detector/nms_c.cc -outdir bin');
eval(cmd);

% compile qp solver
cmd = sprintf('mex qp/qp_one_c.cc -outdir bin');
eval(cmd);

% compile mex utility
cmd = sprintf('mex mex/mex_resize.cc -outdir bin');
eval(cmd);

cmd = sprintf('mex mex/reduce.cc -outdir bin');
eval(cmd);

% compile hashMat with openssl
[~, args] = unix(['pkg-config --cflags --libs openssl']);
cmd = sprintf('mex %s -g mex/hashMat.cc -O -outdir bin %s', ...
              'CXXFLAGS="-O3 \$CXXFLAGS"', args);
try         
    eval(cmd);
catch
    fprintf('Compiling hashMat failed!\n');
    fprintf('    Try to install openssl by "sudo apt install libssl-dev".\n');
end

disp('tbdTracking compiling is done!');

end

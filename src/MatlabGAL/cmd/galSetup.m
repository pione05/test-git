function galSetup(projPath)
% Initial setup for Matlab General Auxiliary Library. Best practise: only
% call this function at the top of project script once.
%
% (1) clear all variables, clean command windows, close all figures, but keep
%     all break points if applicable (updated on Jan 22, 2015)
% (2) add Matlab General Auxiliary Library path to matlab path
% (3) add caller project path (optional)
%
% USAGE
%   galSetup
%
% INPUTS
%   projPath - string, ABSOLUTE project path which should be added to matlab
%              path (optional, default value is the path containing caller file)
%
% OUTPUTS
%
% EXAMPLE
%
% SEE ALSO
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


%% Clear workspace
%clear all variables, clean command windows, close all figures,
%but keep break points if applicable

%method 1: clear variable one by one (it doesn't work, if this code snippet is stored in other file)
%varList = who;
% for vNo = 1:size(varList,1)
%     eval(['clear ' varList{vNo}]);
% end
% clear vNo varList;

%method 2: use evalin + 'caller'
if ~isdeployed
%     evalin('caller', 'varList = who; for vNo = 1:size(varList,1), eval([''clear '' varList{vNo}]); end; clear vNo varList;');
%     evalin('caller', 'clc; close all;');

    evalin('caller', 'close all;');

    %% Add MatlabGAL path
    addpath(genpath(galFullfile(mfilename('fullpath'), '../../../')));

    %addpath(genpath('/scratch/burgundy/yhua/work/MatlabProject/MatlabGAL'));

    %% Add caller project path
    if galSetDefaultVal('projPath', '../')
        [caller, ~] = dbstack('-completenames');
        addpath(genpath(galFullfile(caller(2).file, projPath)));

        [pathstr,name,ext] = fileparts(caller(2).file);
        addpath(genpath(pathstr));
    else
        addpath(genpath(projPath));
    end
end

%% Global variable setting
galGlobalVar;

galMessage('Matlab General Auxiliary Library has been set up successfully!\n');

end

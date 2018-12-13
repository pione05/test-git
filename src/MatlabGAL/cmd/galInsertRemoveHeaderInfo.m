function galInsertRemoveHeaderInfo
% Insert/remove hearer information to all m files.
%
% USAGE
%   galSetup
%
% INPUTS
%
% OUTPUTS
%
% EXAMPLE
%
% SEE ALSO
%
% REFERENCE
%   [1] Piotr Dollar's Toolbox:
%       http://vision.ucsd.edu/~pdollar/toolbox/piotr_toolbox.zip
%
% AUTHORS
%   Yang Hua (Yang.Hua@inria.fr)
%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)
%
% Licensed under the BSD 3-clause license [see license.txt]
%


galSetup('../../');

%% Header information (usually includes copyright and license)
headerInfo = {'% AUTHORS';...
              '%   Yang Hua (Yang.Hua@inria.fr)';...
              '%   Henrique Morimitsu (Henrique.Morimitsu@inria.fr)';...
              '%';... 
              '% Licensed under the BSD 3-clause license [see license.txt]'; ...
              '%'};

%% Toggle insert or remove header information
INSERT_FLAG = true;

%% Search paths (support multiple absolute paths)
searchPath = {'/scratch/burgundy/yhua/work/gforge/pstracker/src/tracker/3rdparty'};

%% Insert header information
if INSERT_FLAG
    galMessage('Starting inserting header information ...\n\n');
else
    galMessage('Starting removing header information ...\n\n');
end

for i = 1:length(searchPath)

    %method 1: use dir to find all subfolders in one layer
%     subFolders = dir(searchPath{i});
%     isub = [subFolders(:).isdir]; %# returns logical vector
%     subFolders = {subFolders(isub).name}';
%     subFolders(ismember(subFolders, {'.', '..'})) = [];
%
%     subFolders{end+1} = '';     %add current path
%
%     for j =1:length(subFolders)
%         galMessage(fullfile(searchPath{i}, subFolders{j}));
%         mFiles = dir(fullfile(searchPath{i}, subFolders{j}, '*.m'));
%
%         if isempty(mFiles)
%             continue;
%         end
%
%         for k=1:length(mFiles);
%             file = fullfile(searchPath{i}, subFolders{j}, mFiles(k).name);
%             galMessage(['--->', file]);
%
% %             if INSERT_FLAG
% %                 inlInsertString(file, headerInfo);
% %             else
% %                 inlRemoveString(file, headerInfo);
% %             end
%         end
%
%     end % for j =1:length(subFolders)

    %method 2: use genpath to find all subfolders in multiple layers
    subFolders = genpath(searchPath{i});
    subFolders = textscan(subFolders, '%s', 'Delimiter', ':');
    subFolders = subFolders{1};

    for j = 1:length(subFolders)
%         [pathstr, name, ext] = fileparts(subFolders{j}); 
%         
%         if strcmp(name, '3rdparty') == 1
%             continue;
%         end
        galMessage([subFolders{j}, '\n']);
        if ~isempty(strfind(subFolders{j}, '3rdparty'))
            galMessage('--->3rdparty folder\n');
            continue;
        end        

        mFiles = dir(fullfile(subFolders{j}, '*.m'));

        if isempty(mFiles)
            continue;
        end

        for k=1:length(mFiles);
            file = fullfile(subFolders{j}, mFiles(k).name);
            galMessage(['--->', file, '\n']);

            if INSERT_FLAG
                inlInsertString(file, headerInfo);
            else
                inlRemoveString(file, headerInfo);
            end
        end
    end
end

end %function

function inlInsertString(file, infoMsg)
    lines = inlReadFile(file);
    nLines = length(lines);

    %find header position
    locCell = strfind(lines, infoMsg{1});
    
    locFlag = false;
    for i = 1:nLines
        if (~isempty(locCell{i}))
            locFlag = true;
            break; 
        end
    end
    
    %Do nothing if can not find header 
    if locFlag
        galWarning('Header information exists!');
        return;
    end
        
    funcNameFlag = true;
    locFlag = false;
    for i = 1:nLines

        if funcNameFlag                 %jump function name
            %empty line
            if length(lines{i}) < 1
                continue;
            end

            if strcmp(lines{i}(1), '%')
                funcNameFlag = false;
                continue;
            end
        else                            %find insert location
            if isempty(lines{i}) || ~strcmp(lines{i}(1), '%')
                loc = i;
                locFlag = true;
                break;
            end
        end

    end %for i = 1:nLines

    if locFlag
        nInfoMsg = length(infoMsg);

        newLines = cell(nLines+nInfoMsg, 1);
        newLines(1:loc-1) = lines(1:loc-1);
        newLines(loc:loc+nInfoMsg-1) = infoMsg(1:nInfoMsg);
        newLines(loc+nInfoMsg:nLines+nInfoMsg) = lines(loc:nLines);

        inlWriteFile(file, newLines);
    else
        galMessage('Can not find proper location to insert header information!');
    end

end

function inlRemoveString(file, infoMsg)
    lines = inlReadFile(file);
    nLines = length(lines);
    
    %find header position
    locCell = strfind(lines, infoMsg{1});
    
    locFlag = false;
    for i = 1:nLines
        if (~isempty(locCell{i}))
            locFlag = true;
            break; 
        end
    end
    
    %Do nothing if can not find header 
    if ~locFlag
        galWarning('Cannot find header information!');
        return;
    end
    
    loc = i;
    
    nInfoMsg = length(infoMsg);
    newLines = cell(nLines-nInfoMsg, 1);
    
    newLines(1:loc-1) = lines(1:loc-1);
    newLines(loc:nLines-nInfoMsg) = lines(loc+nInfoMsg:nLines);
    
    inlWriteFile(file, newLines);   
    
end

function lines = inlReadFile(file)
    fid = fopen(file, 'rt' );
    assert(fid ~= -1);
    lines=cell(10000,1);
    n=0;

    while(1)
        n=n+1;
        lines{n}=fgetl(fid);
        if ~ischar(lines{n})
            break;
        end
    end

    fclose(fid);
    n=n-1;
    lines=lines(1:n);

end

function inlWriteFile(file, lines)
    fid = fopen(file, 'wt');
    for i = 1:length(lines)
        fprintf(fid, '%s\n', lines{i});
    end

    fclose(fid);

end
